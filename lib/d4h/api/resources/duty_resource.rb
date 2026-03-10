# frozen_string_literal: true

module D4H
  module API
    class DutyResource < Resource
      SUB_URL = "duties"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Duty)
      end

      def list_all(**params)
        paginate_all(params, model_class: Duty)
      end

      def show(id:)
        Duty.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
