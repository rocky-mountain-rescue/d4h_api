# frozen_string_literal: true

module D4H
  module API
    class EventResource < Resource
      SUB_URL = "team/events"

      def list(**params)
        Event.new(get_request(SUB_URL, params: params).body)
      end

      def list_all(**params)
        unless params.key?(:limit)
          params[:limit] = 250
        end

        response = get_request(SUB_URL, params: params)

        response_count = response.body["data"].count
        response_total = response_count
        all_response_data = response.body["data"]

        # keep looping until response_count is less than params[:limit]
        # or response_count is 0
        while (response_count != 0) && (response_count >= params[:limit])
          response = get_request(SUB_URL, params: params.merge(offset: response_total))
          all_response_data += response.body["data"]
          response_count = response.body["data"].count
          response_total += response_count
        end

        response.body["data"] = all_response_data
        Event.new(response.body)
      end

      def create(data)
        Event.new(post_request(SUB_URL, body: data).body)
      end
    end
  end
end
