module Api
  module V1
    class IngestController < ApplicationController
      def create
        people = People::BatchIngestService.new(source, people_in_batch).call

        render json: {
          people: people.map { |p| serialize_person(p) }
        }, status: :ok
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
        return src if src && People::IngestService::STRATEGIES.key?(src)
        raise ArgumentError, "Unknown source"
      end

      def people_in_batch
        params.permit(people: person_attributes)[:people] || []
      end

      def person_attributes
        [
          :external_id, :email, :first_name, :last_name, :phone, :company,
          :job_title, :department, :manager_email, :start_date, :updated_at
        ]
      end

      def serialize_person(person)
        person.as_json(
          only: [ :id, :email, :first_name, :last_name, :phone, :company,
                 :job_title, :department, :manager_email, :start_date ],
          include: { external_identities: { only: [ :source, :external_id, :last_synced_at ] } }
        )
      end
    end
  end
end
