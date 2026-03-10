# frozen_string_literal: true

module D4H
  module API
    class HandlerGroupResource < Resource
      SUB_URL = "handler-groups"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: HandlerGroup)
      end

      def list_all(**params)
        paginate_all(params, model_class: HandlerGroup)
      end

      def show(id:)
        HandlerGroup.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        HandlerGroup.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        HandlerGroup.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
