# frozen_string_literal: true

module D4H
  module API
    class EquipmentModelResource < Resource
      SUB_URL = "equipment-models"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentModel)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentModel)
      end

      def show(id:)
        EquipmentModel.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentModel.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentModel.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
