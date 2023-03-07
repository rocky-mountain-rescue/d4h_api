# frozen_string_literal: true

module D4H
  module API
    class CustomFieldForEntityResource < Resource
      SUB_URL = "team/custom-fields"

      def list(**params)
        sub_url = "#{SUB_URL}/#{params[:entity]}/#{params[:entity_id]}"
        CustomField.new get_request(sub_url, params: params).body
      end

      def list_all(**params)
        sub_url  = "#{SUB_URL}/#{params[:entity]}/#{params[:entity_id]}"

        unless params.has_key?(:limit)
          params[:limit] = 250
        end

        response = get_request(sub_url, params: params)

        response_count        = response.body["data"].count
        response_total        = response_count
        all_response_data     = response.body["data"]

        # keep looping until response_count is less than params[:limit]
        # or response_count is 0
        while (response_count != 0) && (response_count >= params[:limit])
          response          = get_request(sub_url, params: params.merge(offset: response_total))
          all_response_data += response.body["data"]
          response_count    = response.body["data"].count
          response_total    += response_count
        end
        response.body["data"] = all_response_data
        CustomField.new response.body
      end

      def update(**params)
        sub_url = "#{SUB_URL}/#{params[:entity]}/#{params[:entity_id]}"
        put_request(sub_url, body: params.except(:entity, :entity_id))
      end
    end
  end
end
