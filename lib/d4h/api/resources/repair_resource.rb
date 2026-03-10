# frozen_string_literal: true

module D4H
  module API
    class RepairResource < Resource
      SUB_URL = "repairs"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Repair)
      end

      def list_all(**params)
        paginate_all(params, model_class: Repair)
      end

      def show(id:)
        Repair.new(get_request("#{resource_url}/#{id}").body)
      end

      def create(data)
        Repair.new(post_request(resource_url, body: data).body)
      end

      def update(id:, **params)
        Repair.new(patch_request("#{resource_url}/#{id}", body: params).body)
      end

      def destroy(id:)
        delete_request("#{resource_url}/#{id}")
      end
    end
  end
end
