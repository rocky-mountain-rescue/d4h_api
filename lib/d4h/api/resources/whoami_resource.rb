# frozen_string_literal: true

module D4H
  module API
    class WhoamiResource < Resource
      SUB_URL = "whoami"

      def show
        Whoami.new(get_request("#{base_path}/#{SUB_URL}").body)
      end
    end
  end
end
