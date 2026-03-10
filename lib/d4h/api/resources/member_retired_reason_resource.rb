# frozen_string_literal: true

module D4H
  module API
    class MemberRetiredReasonResource < Resource
      SUB_URL = "member-retired-reasons"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: MemberRetiredReason)
      end

      def list_all(**params)
        paginate_all(params, model_class: MemberRetiredReason)
      end
    end
  end
end
