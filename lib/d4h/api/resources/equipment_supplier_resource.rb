# frozen_string_literal: true

module D4H
  module API
    class EquipmentSupplierResource < Resource
      SUB_URL = "equipment-suppliers"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentSupplier)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentSupplier)
      end

      def show(id:)
        EquipmentSupplier.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentSupplier.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentSupplier.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
