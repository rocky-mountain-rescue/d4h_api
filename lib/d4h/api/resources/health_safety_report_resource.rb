# frozen_string_literal: true

module D4H
  module API
    class HealthSafetyReportResource < Resource
      SUB_URL = "health-safety-reports"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: HealthSafetyReport)
      end

      def list_all(**params)
        paginate_all(params, model_class: HealthSafetyReport)
      end

      def show(id:)
        HealthSafetyReport.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
