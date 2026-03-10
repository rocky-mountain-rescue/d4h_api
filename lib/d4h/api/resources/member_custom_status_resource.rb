# frozen_string_literal: true

module D4H
  module API
    class MemberCustomStatusResource < Resource
      SUB_URL = "member-custom-statuses"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: MemberCustomStatus)
      end

      def list_all(**params)
        paginate_all(params, model_class: MemberCustomStatus)
      end
    end
  end
end
