# frozen_string_literal: true

module D4H
  module API
    class DocumentResource < Resource
      SUB_URL = "documents"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Document)
      end

      def list_all(**params)
        paginate_all(params, model_class: Document)
      end

      def show(id:)
        Document.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        Document.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        Document.new(put_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
