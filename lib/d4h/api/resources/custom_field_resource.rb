# frozen_string_literal: true

module D4H
  module API
    class CustomFieldResource < Resource
      SUB_URL = "custom-fields"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: CustomField)
      end

      def list_all(**params)
        paginate_all(params, model_class: CustomField)
      end

      def show(id:)
        CustomField.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        CustomField.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        CustomField.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
