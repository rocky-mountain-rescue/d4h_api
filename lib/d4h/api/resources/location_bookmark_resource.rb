# frozen_string_literal: true

module D4H
  module API
    class LocationBookmarkResource < Resource
      SUB_URL = "location-bookmarks"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: LocationBookmark)
      end

      def list_all(**params)
        paginate_all(params, model_class: LocationBookmark)
      end

      def show(id:)
        LocationBookmark.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
