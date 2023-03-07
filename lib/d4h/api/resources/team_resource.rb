# frozen_string_literal: true

module D4H
  module API
    class TeamResource < Resource
      def show
        Team.new get_request("team").body
      end
    end
  end
end
