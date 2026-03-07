class AuthService
  class AuthenticationError < StandardError; end
  class TokenExpiredError < StandardError; end
  class TokenInvalidError < StandardError; end

  # Use environment variable for JWT secret key
  # In production: require JWT_SECRET_KEY to be set
  # In development/test: fall back to Rails secret_key_base or fallback
  SECRET_KEY = if Rails.env.production?
                 ENV.fetch("JWT_SECRET_KEY") do
                   raise ArgumentError, "JWT_SECRET_KEY environment variable is not set in production"
                 end
  else
                 ENV["JWT_SECRET_KEY"] || Rails.application.credentials.secret_key_base || "dev_fallback_secret_key"
  end

  TOKEN_EXPIRATION = 24.hours

  def self.authenticate(email, password)
    person = Person.find_by(email: email.downcase)

    raise AuthenticationError, "Invalid credentials" unless person&.authenticate(password)

    person
  end

  def self.generate_token(person_id)
    payload = {
      person_id: person_id,
      exp: TOKEN_EXPIRATION.from_now.to_i,
      iat: Time.current.to_i
    }

    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode_token(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
    decoded[0]
  rescue JWT::ExpiredSignature
    raise TokenExpiredError, "Token has expired"
  rescue JWT::DecodeError => e
    raise TokenInvalidError, "Invalid token"
  end

  def self.current_person(token)
    decoded = decode_token(token)
    person_id = decoded["person_id"]

    Person.find_by(id: person_id)
  end
end
