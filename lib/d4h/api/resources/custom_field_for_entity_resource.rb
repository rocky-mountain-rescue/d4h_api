module D4H
  module API
    class CustomFieldForEntityResource < Resource
      SUB_URL_PREFIX = "team/custom-fields"

      def get(**params)
        sub_url = SUB_URL_PREFIX + "/#{params[:entity]}/#{params[:entity_id]}"
        CustomField.new get_request(sub_url, params: params).body
      end

      def get_all(**params)
        sub_url = SUB_URL_PREFIX + "/#{params[:entity]}/#{params[:entity_id]}"
        params[:limit] = 250 unless params.has_key?(:limit)
        response       = get_request(sub_url, params: params)

        response_event_count  = response.body["data"].count
        response_event_total  = response_event_count
        all_response_data     = response.body["data"]

        # keep looping until response_event_count is less than params[:limit]
        # or response_event_count is 0
        while (response_event_count != 0) && (response_event_count >= params[:limit])
          response             = get_request(sub_url, params: params.merge(offset: response_event_total))
          all_response_data    += response.body["data"]
          response_event_count = response.body["data"].count
          response_event_total += response_event_count
        end
        response.body["data"] = all_response_data
        CustomField.new response.body
      end

      def put(data)
        sub_url = SUB_URL_PREFIX + "/#{params[:entity]}/#{params[:entity_id]}"
        put_request(sub_url, body: data)
      end
    end
  end
end
