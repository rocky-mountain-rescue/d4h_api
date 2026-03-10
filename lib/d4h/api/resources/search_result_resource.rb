# frozen_string_literal: true

module D4H
  module API
    class SearchResultResource < Resource
      SUB_URL = "search"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: SearchResult)
      end

      def list_all(**params)
        paginate_all(params, model_class: SearchResult)
      end
    end
  end
end
