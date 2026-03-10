# frozen_string_literal: true

module D4H
  module API
    class CustomerIdentifierResource < Resource
      SUB_URL = "customer-identifiers"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: CustomerIdentifier)
      end

      def list_all(**params)
        paginate_all(params, model_class: CustomerIdentifier)
      end
    end
  end
end
