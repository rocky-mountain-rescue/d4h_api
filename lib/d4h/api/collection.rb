# frozen_string_literal: true

module D4H
  module API
    # Public: An Enumerable wrapper around a paginated D4H API list response.
    #
    # Parses the standard D4H v3 list envelope — which contains "results",
    # "page", "pageSize", and "totalSize" — and converts each result into
    # the given model class.
    #
    # Includes Enumerable, so you can call `map`, `select`, `first`, `count`,
    # and any other Enumerable method directly on a collection.
    #
    # Examples
    #
    #   collection = client.member.list
    #   collection.total_size          # => 90
    #   collection.page                # => 0
    #   collection.map(&:name)         # => ["Alice", "Bob", ...]
    #   collection.first.status        # => "OPERATIONAL"
    #   collection.select { |m| m.status == "OPERATIONAL" }
    #
    #   # Raw JSON envelope
    #   collection.to_json  # => {"results" => [...], "page" => 0, ...}
    class Collection
      # Public: Returns the Array of Model instances from this page.
      # Public: Returns the zero-based page number.
      # Public: Returns the page size (number of results per page).
      # Public: Returns the total number of results across all pages.
      # Public: Returns the original JSON hash envelope.
      attr_reader :results, :page, :page_size, :total_size, :to_json

      # Public: Initialize a Collection from a parsed JSON response body.
      #
      # body        - A Hash with "results", "page", "pageSize", "totalSize" keys.
      # model_class - The Model subclass to wrap each result in (e.g. Member, Event).
      def initialize(body, model_class:)
        @to_json = body
        @results = (body["results"] || []).map { |attrs| model_class.new(attrs) }
        @page = body["page"]
        @page_size = body["pageSize"]
        @total_size = body["totalSize"]
      end

      include Enumerable

      # Public: Yield each Model in the results array.
      #
      # Yields each Model instance.
      def each(&block)
        results.each(&block)
      end
    end
  end
end
