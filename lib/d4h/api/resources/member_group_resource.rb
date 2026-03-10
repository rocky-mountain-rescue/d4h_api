# frozen_string_literal: true

module D4H
  module API
    class MemberGroupResource < Resource
      SUB_URL = "member-groups"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: MemberGroup)
      end

      def list_all(**params)
        paginate_all(params, model_class: MemberGroup)
      end

      def show(id:)
        MemberGroup.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        MemberGroup.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        MemberGroup.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
