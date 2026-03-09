module Api
  module V1
    class IngestController < ApplicationController
      def create
        ActiveRecord::Base.transaction do
          results = people_in_batch.map do |person_data|
            People::IngestService.new(source, person_data).call
          end

          render json: {
            people: results.map { |p| { id: p.id, email: p.email } }
          }, status: :ok
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: {
          error: "Validation failed",
          details: e.record.errors.full_messages
        }, status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error "Ingest Error: #{e.message}"
        render json: { error: "Internal Server Error: #{e.message}" }, status: :internal_server_error
      end

      private

      def source
        src = params[:source]&.to_sym
        if src && People::IngestService::STRATEGIES.key?(src)
          return src
        end

        raise ArgumentError, "Unknown source"
      end

      def people_in_batch
        permitted = params.permit(people: person_attributes)
        permitted[:people] || []
      end

      def person_attributes
        [
          :external_id, :email, :first_name, :last_name, :phone, :company,
          :job_title, :department, :manager_email, :start_date, :updated_at
        ]
      end
    end
  end
end
