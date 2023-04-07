# frozen_string_literal: true

require "faraday"
require "faraday/middleware"

module D4H
  module API
    class Client
      BASE_URL = ENV.fetch("D4H_BASE_URL", "http://api.d4h.test/v2")
      attr_reader :api_key, :adapter

      def initialize(api_key:, adapter: Faraday.default_adapter)
        @api_key = api_key
        @adapter = adapter
      end

      def connection
        @connection ||= Faraday.new do |connection|
          connection.adapter(adapter)
          connection.url_prefix = BASE_URL
          connection.request(:url_encoded)
          connection.response(:json, content_type: "application/json")
        end
      end

      def custom_field
        CustomFieldResource.new(self)
      end

      def custom_field_for_entity
        CustomFieldForEntityResource.new(self)
      end

      def event
        EventResource.new(self)
      end

      def incident
        IncidentResource.new(self)
      end

      def inspect
        "#<D4H::Client>"
      end

      def team
        TeamResource.new(self)
      end
    end
  end
end
