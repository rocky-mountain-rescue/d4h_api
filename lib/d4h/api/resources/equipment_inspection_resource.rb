# frozen_string_literal: true

module D4H
  module API
    class EquipmentInspectionResource < Resource
      SUB_URL = "equipment-inspections"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentInspection)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentInspection)
      end

      def show(id:)
        EquipmentInspection.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
