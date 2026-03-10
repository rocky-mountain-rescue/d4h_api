# frozen_string_literal: true

module D4H
  module API
    class HandlerGroupMembershipResource < Resource
      SUB_URL = "handler-group-memberships"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: HandlerGroupMembership)
      end

      def list_all(**params)
        paginate_all(params, model_class: HandlerGroupMembership)
      end

      def show(id:)
        HandlerGroupMembership.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
