module People
  class QueryService
    include Pagy::Backend

    attr_reader :params

    def initialize(params = {})
      @params = params
    end

    def call
      scope = Person.includes(:external_identities).all
      scope = filter_by_email(scope)
      scope = filter_by_department(scope)
      scope = filter_by_source(scope)

      pagy(scope, items: params[:per_page] || 20)
    end

    private

    def filter_by_email(scope)
      return scope unless params[:email].present?
      scope.where("lower(email) = ?", params[:email].downcase)
    end

    def filter_by_source(scope)
      return scope unless params[:source].present?
      scope.joins(:external_identities).where(external_identities: { source: params[:source] })
    end

    def filter_by_department(scope)
      return scope unless params[:department].present?
      scope.where(department: params[:department])
    end
  end
end
