# frozen_string_literal: true

module D4H
  module API
    class EquipmentLocationResource < Resource
      SUB_URL = "equipment-locations"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentLocation)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentLocation)
      end

      def show(id:)
        EquipmentLocation.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
