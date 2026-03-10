# frozen_string_literal: true

module D4H
  module API
    class D4hModuleResource < Resource
      SUB_URL = "modules"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: D4hModule)
      end

      def list_all(**params)
        paginate_all(params, model_class: D4hModule)
      end
    end
  end
end
