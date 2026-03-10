# frozen_string_literal: true

module D4H
  module API
    class IncidentInvolvedInjuryResource < Resource
      SUB_URL = "incident-involved-injuries"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: IncidentInvolvedInjury)
      end

      def list_all(**params)
        paginate_all(params, model_class: IncidentInvolvedInjury)
      end

      def show(id:)
        IncidentInvolvedInjury.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
