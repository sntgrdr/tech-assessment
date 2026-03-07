class ApplicationController < ActionController::API
  include Authenticatable
  include Pagy::Backend
end
