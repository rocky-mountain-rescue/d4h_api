# frozen_string_literal: true

module D4H
  module API
    class EquipmentInspectionResultResource < Resource
      SUB_URL = "equipment-inspection-results"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentInspectionResult)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentInspectionResult)
      end

      def show(id:)
        EquipmentInspectionResult.new(get_request("#{resource_url}/#{id}").body)
      end

      def update(id:, **params)
        EquipmentInspectionResult.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
