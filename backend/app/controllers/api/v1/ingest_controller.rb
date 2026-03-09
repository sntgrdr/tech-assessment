module Api
  module V1
    class IngestController < ApplicationController
      def create
        person = People::IngestService.new(source, payload).call

        render json: { id: person.id }, status: :ok
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def source
        src = params[:source].to_sym

        unless People::IngestService::STRATEGIES.key?(src)
          raise ArgumentError, "Unknown source"
        end

        src
      end

      def payload
        params.permit(:external_id, :email, :first_name, :last_name, :phone, :company, :job_title, :department, :manager_email, :start_date).to_h
      end
    end
  end
end
