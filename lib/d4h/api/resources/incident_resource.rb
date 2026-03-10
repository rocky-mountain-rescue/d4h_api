# frozen_string_literal: true

module D4H
  module API
    class IncidentResource < Resource
      SUB_URL = "incidents"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Incident)
      end

      def list_all(**params)
        paginate_all(params, model_class: Incident)
      end

      def show(id:)
        Incident.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        Incident.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        Incident.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end
    end
  end
end
