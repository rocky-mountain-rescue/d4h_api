# frozen_string_literal: true

module D4H
  module API
    class CustomFieldForEntityResource < Resource
      SUB_URL = "custom-field-options"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: CustomFieldForEntity)
      end

      def show(id:)
        CustomFieldForEntity.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
