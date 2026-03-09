module People
  class NormalizationService
    def self.call(data)
      new(data).call
    end

    def initialize(data)
      @data = data
    end

    def call
      normalized = data.dup

      normalized[:email] = normalize_email(data[:email])
      normalized[:first_name] = normalize_string(data[:first_name])
      normalized[:last_name] = normalize_string(data[:last_name])
      normalized[:phone] = normalize_phone(data[:phone])
      normalized[:company] = normalize_string(data[:company])
      normalized[:manager_email] = normalize_email(data[:manager_email])
      normalized[:start_date] = normalize_date(data[:start_date])

      normalized
    end

    private

    attr_reader :data

    def normalize_email(email)
      email&.strip&.downcase
    end

    def normalize_string(str)
      str&.strip
    end

    def normalize_phone(phone)
      phone&.gsub(/\D/, "")
    end

    def normalize_date(date)
      Date.parse(date.to_s) rescue nil
    end
  end
end
