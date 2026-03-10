# frozen_string_literal: true

module D4H
  module API
    class EventResource < Resource
      SUB_URL = "events"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Event)
      end

      def list_all(**params)
        paginate_all(params, model_class: Event)
      end

      def show(id:)
        Event.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        Event.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        Event.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end
    end
  end
end
