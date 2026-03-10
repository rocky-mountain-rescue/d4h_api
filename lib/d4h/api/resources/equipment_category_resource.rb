# frozen_string_literal: true

module D4H
  module API
    class EquipmentCategoryResource < Resource
      SUB_URL = "equipment-categories"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentCategory)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentCategory)
      end

      def show(id:)
        EquipmentCategory.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentCategory.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentCategory.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
