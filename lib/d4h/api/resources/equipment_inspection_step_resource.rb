# frozen_string_literal: true

module D4H
  module API
    class EquipmentInspectionStepResource < Resource
      SUB_URL = "equipment-inspection-steps"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: EquipmentInspectionStep)
      end

      def list_all(**params)
        paginate_all(params, model_class: EquipmentInspectionStep)
      end

      def show(id:)
        EquipmentInspectionStep.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        EquipmentInspectionStep.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        EquipmentInspectionStep.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
