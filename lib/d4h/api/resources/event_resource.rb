module D4H
  module API
    class EventResource < Resource
      def list(**params)
        Event.new get_request("team/events", params: params).body
      end

      def list_all(**params)
        params[:limit] = 250 unless params.has_key?(:limit)
        response       = get_request("team/events", params: params)

        response_event_count  = response.body["data"].count
        response_event_total  = response_event_count
        all_response_data     = response.body["data"]

        # keep looping until response_event_count is less than params[:limit]
        # or response_event_count is 0
        while !(response_event_count == 0) && !(response_event_count < params[:limit])
          response             = get_request("team/events", params: params.merge(offset: response_event_total))
          all_response_data    += response.body["data"]
          response_event_count = response.body["data"].count
          response_event_total += response_event_count
        end
        response.body["data"] = all_response_data
        Event.new response.body
      end

      def create(**attributes)
        post_request("events",)
      end
    end
  end
end
