# frozen_string_literal: true

module D4H
  module API
    class EquipmentFundResource < Resource
      SUB_URL = "equipment-funds"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentFund)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentFund)
      end

      def show(id:)
        EquipmentFund.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentFund.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentFund.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
