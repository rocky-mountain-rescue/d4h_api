# frozen_string_literal: true

module D4H
  module API
    class MemberGroupMembershipResource < Resource
      SUB_URL = "member-group-memberships"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: MemberGroupMembership)
      end

      def list_all(**params)
        paginate_all(params, model_class: MemberGroupMembership)
      end

      def show(id:)
        MemberGroupMembership.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
