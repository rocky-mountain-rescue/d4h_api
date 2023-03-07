module D4H
  module API
    class CustomFieldResource < Resource
      SUB_URL = "team/custom-fields"

      def list(**params)
        CustomField.new get_request(SUB_URL, params: params).body
      end

      def list_all(**params)
        params[:limit] = 250 unless params.has_key?(:limit)
        response       = get_request(SUB_URL, params: params)

        response_event_count  = response.body["data"].count
        response_event_total  = response_event_count
        all_response_data     = response.body["data"]

        # keep looping until response_event_count is less than params[:limit]
        # or response_event_count is 0
        while !(response_event_count == 0) && !(response_event_count < params[:limit])
          response             = get_request("team/custom-fields", params: params.merge(offset: response_event_total))
          all_response_data    += response.body["data"]
          response_event_count = response.body["data"].count
          response_event_total += response_event_count
        end
        response.body["data"] = all_response_data
        CustomField.new response.body
      end

      def create(data)
        post_request(SUB_URL, body: data)
      end
    end
  end
end
