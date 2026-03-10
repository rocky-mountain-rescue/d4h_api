# frozen_string_literal: true

module D4H
  module API
    class IncidentInvolvedMetadataResource < Resource
      SUB_URL = "incident-involved-metadata"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: IncidentInvolvedMetadata)
      end

      def list_all(**params)
        paginate_all(params, model_class: IncidentInvolvedMetadata)
      end
    end
  end
end
