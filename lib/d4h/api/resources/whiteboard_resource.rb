# frozen_string_literal: true

module D4H
  module API
    class WhiteboardResource < Resource
      SUB_URL = "whiteboard"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Whiteboard)
      end

      def list_all(**params)
        paginate_all(params, model_class: Whiteboard)
      end

      def show(id:)
        Whiteboard.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        Whiteboard.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        Whiteboard.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
