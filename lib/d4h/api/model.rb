# frozen_string_literal: true

require "ostruct"

module D4H
  module API
    # Public: Base class for all D4H API response models.
    #
    # Wraps a JSON response hash in an OpenStruct so that attributes are
    # accessible via dot-notation. Nested hashes and arrays are recursively
    # converted, allowing deep attribute traversal.
    #
    # Subclasses (e.g. Member, Event, Equipment) are thin wrappers that
    # exist primarily for type identification via `kind_of?`.
    #
    # Examples
    #
    #   model = D4H::API::Model.new({"id" => 1, "name" => "Alice"})
    #   model.id    # => 1
    #   model.name  # => "Alice"
    #
    #   # Nested data
    #   model = D4H::API::Model.new({"brand" => {"title" => "Petzl"}})
    #   model.brand.title  # => "Petzl"
    #
    #   # Raw JSON hash
    #   model.to_json  # => {"id" => 1, "name" => "Alice"}
    class Model < OpenStruct
      # Public: Returns the original JSON hash that was used to build this model.
      attr_reader :to_json

      # Public: Initialize a Model from a JSON response hash.
      #
      # attributes - A Hash of key/value pairs from the API response.
      def initialize(attributes)
        super(to_ostruct(attributes))
        @to_json = attributes
      end

      # Internal: Recursively convert a parsed JSON object into OpenStructs.
      #
      # obj - A Hash, Array, or scalar value from the parsed JSON.
      #
      # Returns an OpenStruct (for Hash), Array of converted values, or the
      # original scalar.
      def to_ostruct(obj)
        if obj.is_a?(Hash)
          OpenStruct.new(obj.map { |key, val| [key, to_ostruct(val)] }.to_h)
        elsif obj.is_a?(Array)
          obj.map { |o| to_ostruct(o) }
        else
          obj
        end
      end
    end
  end
end
