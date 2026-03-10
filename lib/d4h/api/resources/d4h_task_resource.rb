# frozen_string_literal: true

module D4H
  module API
    class D4hTaskResource < Resource
      SUB_URL = "tasks"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: D4hTask)
      end

      def list_all(**params)
        paginate_all(params, model_class: D4hTask)
      end
    end
  end
end
