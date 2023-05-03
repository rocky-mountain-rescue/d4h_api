# frozen_string_literal: true

require "ostruct"

module D4H
  module API
    class Model < OpenStruct
      attr_reader :to_json

      def initialize(attributes)
        super(to_ostruct(attributes))
        @to_json = attributes
      end

      def to_ostruct(obj)
        if obj.is_a?(Hash)
          OpenStruct.new(obj.map { |key, val| [key, to_ostruct(val)] }.to_h)
        elsif obj.is_a?(Array)
          obj.map { |o| to_ostruct(o) }
        else
          # Assumed to be a primitive value
          obj
        end
      end

      def success?
        (200..299).cover?(statusCode)
      end

      def failure?
        !success?
      end
    end
  end
end
