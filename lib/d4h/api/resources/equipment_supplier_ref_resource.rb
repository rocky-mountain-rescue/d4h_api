# frozen_string_literal: true

module D4H
  module API
    class EquipmentSupplierRefResource < Resource
      SUB_URL = "equipment-supplier-refs"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentSupplierRef)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentSupplierRef)
      end

      def show(id:)
        EquipmentSupplierRef.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentSupplierRef.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentSupplierRef.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
