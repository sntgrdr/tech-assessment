module Api
  module V1
    class PeopleController < ApplicationController
      include Pagy::Backend

      def index
        pagy_obj, people = People::QueryService.new(query_params).call

        render json: {
          people: people.as_json(include: :external_identities),
          pagination: pagy_metadata(pagy_obj)
        }, status: :ok
      end

      def show
        person = Person.find(params[:id])
        render json: person.as_json(include: :external_identities), status: :ok
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      private

      def query_params
        params.permit(:email, :source, :department, :page, :per_page)
      end
    end
  end
end
