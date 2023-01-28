module D4H
  class TeamResource < Resource
    def details
      Team.new get_request( "team").body
    end
  end
end
