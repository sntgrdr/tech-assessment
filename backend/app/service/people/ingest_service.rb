module People
  class IngestService
    STRATEGIES = {
      crm: People::PayloadStrategies::CrmPayloadStrategy,
      hrm: People::PayloadStrategies::HrmPayloadStrategy
    }.freeze

    def initialize(source, data)
      @source = source
      @data = data
    end

    def call
      raise ArgumentError, "Email is required" if data[:email].blank?

      ActiveRecord::Base.transaction do
        person = find_or_create_person
        create_external_identity(person)

        person
      end
    end

    private

    attr_reader :source, :data

    def find_or_create_person
      Person.find_or_initialize_by(email: data[:email]&.downcase!).tap do |person|
        person.update!(person_attributes)
      end
    end

    def person_attributes
      strategy.person_attributes
    end

    def strategy
      @strategy ||= STRATEGIES[source.to_sym].new(data)
    end

    def create_external_identity(person)
      People::ExternalIdentitySyncService.new(person, source, data[:external_id]).call
    end
  end
end
