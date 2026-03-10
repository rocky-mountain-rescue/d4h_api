# frozen_string_literal: true

module D4H
  module API
    class TeamResource < Resource
      SUB_URL = "teams"

      def show(id:)
        Team.new(get_request("#{resource_url}/#{id}").body)
      end
    end
  end
end
