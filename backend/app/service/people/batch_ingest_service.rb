module People
  class BatchIngestService
    attr_reader :source, :people_data

    def initialize(source, people_data)
      @source = source
      @people_data = people_data
    end

    def call
      return [] if people_data.empty?

      ActiveRecord::Base.transaction do
        people_data.map do |person_data|
          person_data[:email]&.downcase!
          IngestService.new(source, person_data).call
        end
      end
    end
  end
end
