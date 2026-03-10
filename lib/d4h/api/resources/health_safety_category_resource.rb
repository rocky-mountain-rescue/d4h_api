# frozen_string_literal: true

module D4H
  module API
    class HealthSafetyCategoryResource < Resource
      SUB_URL = "health-safety-categories"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: HealthSafetyCategory)
      end

      def list_all(**params)
        paginate_all(params, model_class: HealthSafetyCategory)
      end

      def show(id:)
        HealthSafetyCategory.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        HealthSafetyCategory.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        HealthSafetyCategory.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
