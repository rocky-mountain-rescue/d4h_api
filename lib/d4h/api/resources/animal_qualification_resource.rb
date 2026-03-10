# frozen_string_literal: true

module D4H
  module API
    class AnimalQualificationResource < Resource
      SUB_URL = "animal-qualifications"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: AnimalQualification)
      end

      def list_all(**params)
        paginate_all(params, model_class: AnimalQualification)
      end

      def show(id:)
        AnimalQualification.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
