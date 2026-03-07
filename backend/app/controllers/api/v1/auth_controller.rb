class Api::V1::AuthController < ApplicationController
  def login
    person = AuthService.authenticate(params[:email], params[:password])
    token = AuthService.generate_token(person.id)

    render json: {
      person: person.as_json(only: [ :id, :email, :first_name, :last_name ]),
      token: token
    }, status: :ok
  rescue AuthService::AuthenticationError => e
    render json: { error: e.message }, status: :unauthorized
  end

  def logout
    render json: { message: "Logged out successfully" }, status: :ok
  end

  def current_user
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    if token
      begin
        person = AuthService.current_person(token)
        if person
          render json: person.as_json(only: [ :id, :email, :first_name, :last_name ])
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      rescue AuthService::AuthenticationError, AuthService::TokenExpiredError, AuthService::TokenInvalidError
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
