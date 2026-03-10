# frozen_string_literal: true

module D4H
  module API
    class EquipmentBrandResource < Resource
      SUB_URL = "equipment-brands"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentBrand)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentBrand)
      end

      def show(id:)
        EquipmentBrand.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentBrand.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentBrand.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
