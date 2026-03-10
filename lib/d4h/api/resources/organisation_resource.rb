# frozen_string_literal: true

module D4H
  module API
    class OrganisationResource < Resource
      SUB_URL = "organisations"

      def show(id:)
        Organisation.new(get_request("#{base_path}/#{SUB_URL}/#{id}").body)
      end
    end
  end
end
