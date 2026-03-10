# frozen_string_literal: true

module D4H
  module API
    class MemberQualificationResource < Resource
      SUB_URL = "member-qualifications"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: MemberQualification)
      end

      def list_all(**params)
        paginate_all(params, model_class: MemberQualification)
      end

      def show(id:)
        MemberQualification.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
