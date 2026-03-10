# frozen_string_literal: true

module D4H
  module API
    class EquipmentResource < Resource
      SUB_URL = "equipment"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Equipment)
      end

      def list_all(**params)
        paginate_all(params, model_class: Equipment)
      end

      def show(id:)
        Equipment.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        Equipment.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        Equipment.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
