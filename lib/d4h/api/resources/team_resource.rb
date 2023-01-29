module D4H
  module API
    class TeamResource < Resource
      def details
        Team.new get_request("team").body
      end
    end
  end
end
