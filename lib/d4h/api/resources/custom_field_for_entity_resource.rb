# frozen_string_literal: true

module D4H
  module API
    class CustomFieldForEntityResource < Resource
      SUB_URL = "team/custom-fields"

      def list(**params)
        sub_url = "#{SUB_URL}/#{params[:entity]}/#{params[:entity_id]}"
        CustomFieldForEntity.new get_request(sub_url, params: params.except(:entity, :entity_id)).body
      end

      def list_all(**params)
        sub_url  = "#{SUB_URL}/#{params[:entity]}/#{params[:entity_id]}"

        unless params.has_key?(:limit)
          params[:limit] = 250
        end

        response = get_request(sub_url, params: params.except(:entity, :entity_id))

        response_count        = response.body["data"].count
        response_total        = response_count
        all_response_data     = response.body["data"]

        # keep looping until response_count is less than params[:limit]
        # or response_count is 0
        while (response_count != 0) && (response_count >= params[:limit])
          response          = get_request(sub_url,
                                          params: params.except(:entity, :entity_id).merge(offset: response_total))
          all_response_data += response.body["data"]
          response_count    = response.body["data"].count
          response_total    += response_count
        end
        response.body["data"] = all_response_data
        CustomFieldForEntity.new response.body
      end

      def update(body:, entity:, entity_id:)
        sub_url = "#{SUB_URL}/#{entity}/#{entity_id}"
        CustomFieldForEntity.new put_request(sub_url, body: body).body
      end
    end
  end
end
