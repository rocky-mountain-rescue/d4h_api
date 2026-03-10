# frozen_string_literal: true

module D4H
  module API
    class EquipmentInspectionStepResultResource < Resource
      SUB_URL = "equipment-inspection-step-results"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentInspectionStepResult)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentInspectionStepResult)
      end

      def show(id:)
        EquipmentInspectionStepResult.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentInspectionStepResult.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentInspectionStepResult.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
