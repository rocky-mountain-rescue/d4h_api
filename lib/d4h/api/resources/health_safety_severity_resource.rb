# frozen_string_literal: true

module D4H
  module API
    class HealthSafetySeverityResource < Resource
      SUB_URL = "health-safety-severities"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: HealthSafetySeverity)
      end

      def list_all(**params)
        paginate_all(params, model_class: HealthSafetySeverity)
      end

      def show(id:)
        HealthSafetySeverity.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        HealthSafetySeverity.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        HealthSafetySeverity.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
