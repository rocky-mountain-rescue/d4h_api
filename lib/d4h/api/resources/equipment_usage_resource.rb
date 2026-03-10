# frozen_string_literal: true

module D4H
  module API
    class EquipmentUsageResource < Resource
      SUB_URL = "equipment-usages"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentUsage)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentUsage)
      end

      def show(id:)
        EquipmentUsage.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentUsage.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentUsage.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
