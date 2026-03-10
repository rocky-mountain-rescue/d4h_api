# frozen_string_literal: true

module D4H
  module API
    class RoleResource < Resource
      SUB_URL = "roles"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Role)
      end

      def list_all(**params)
        paginate_all(params, model_class: Role)
      end

      def show(id:)
        Role.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
