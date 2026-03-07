module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
    rescue_from AuthService::AuthenticationError, with: :unauthorized_request
    rescue_from AuthService::TokenExpiredError, with: :unauthorized_request
    rescue_from AuthService::TokenInvalidError, with: :unauthorized_request
  end

  private

  def authenticate_request!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    raise AuthService::AuthenticationError unless token

    @current_person = AuthService.current_person(token)
    raise AuthService::AuthenticationError unless @current_person
  end

  def unauthorized_request
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def current_person
    @current_person
  end
end
