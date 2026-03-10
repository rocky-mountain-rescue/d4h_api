# frozen_string_literal: true

module D4H
  module API
    class HandlerQualificationResource < Resource
      SUB_URL = "handler-qualifications"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: HandlerQualification)
      end

      def list_all(**params)
        paginate_all(params, model_class: HandlerQualification)
      end

      def show(id:)
        HandlerQualification.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
