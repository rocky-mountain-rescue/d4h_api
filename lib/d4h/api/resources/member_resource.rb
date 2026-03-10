# frozen_string_literal: true

module D4H
  module API
    class MemberResource < Resource
      SUB_URL = "members"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Member)
      end

      def list_all(**params)
        paginate_all(params, model_class: Member)
      end

      def update(id:, **params)
        Member.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end
    end
  end
end
