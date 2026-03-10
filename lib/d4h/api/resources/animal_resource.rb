# frozen_string_literal: true

module D4H
  module API
    class AnimalResource < Resource
      SUB_URL = "animals"

      def list(**params)
        Collection.new(get_request(resource_url, params: params).body, model_class: Animal)
      end

      def list_all(**params)
        paginate_all(params, model_class: Animal)
      end

      def show(id:)
        Animal.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
