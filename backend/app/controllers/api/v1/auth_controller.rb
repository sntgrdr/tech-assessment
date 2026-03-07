class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request!, only: [ :login ]

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
    render json: {
      person: current_person.as_json(only: [ :id, :email, :first_name, :last_name ])
    }
  end
end
