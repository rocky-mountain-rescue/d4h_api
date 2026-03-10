# frozen_string_literal: true

module D4H
  module API
    class EquipmentKindResource < Resource
      SUB_URL = "equipment-kinds"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentKind)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentKind)
      end

      def show(id:)
        EquipmentKind.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentKind.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentKind.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
