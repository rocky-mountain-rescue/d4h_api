# frozen_string_literal: true

module D4H
  module API
    class EquipmentRetiredReasonResource < Resource
      SUB_URL = "equipment-retired-reasons"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentRetiredReason)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentRetiredReason)
      end

      def show(id:)
        EquipmentRetiredReason.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentRetiredReason.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentRetiredReason.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
