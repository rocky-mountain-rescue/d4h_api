# frozen_string_literal: true

module D4H
  module API
    # Public: Base class for all D4H API resource endpoints.
    #
    # Provides HTTP verb helpers (GET, POST, PUT, PATCH, DELETE), automatic
    # Bearer token authentication, error handling, and a pagination helper
    # for fetching all pages of a list endpoint.
    #
    # Subclasses must define a `SUB_URL` constant (e.g. "members", "tags")
    # and implement whichever CRUD methods the API supports for that resource.
    #
    # Examples
    #
    #   class TagResource < Resource
    #     SUB_URL = "tags"
    #
    #     def list(**params)
    #       Collection.new(get_request(resource_url, params: params).body, model_class: Tag)
    #     end
    #
    #     def show(id:)
    #       Tag.new(get_request("#{resource_url}/#{id}").body)
    #     end
    #   end
    class Resource
      # Public: Returns the Client instance this resource is bound to.
      attr_reader :client

      # Public: Initialize a Resource bound to a Client.
      #
      # client - A D4H::API::Client instance.
      def initialize(client)
        @client = client
      end

      # Public: Returns the context-scoped base path (e.g. "v3/team/42").
      def base_path
        client.base_path
      end

      # Public: Returns the full resource URL path (e.g. "v3/team/42/tags").
      #
      # Built from the client's base_path and the subclass's SUB_URL constant.
      def resource_url
        "#{base_path}/#{self.class::SUB_URL}"
      end

      # Public: Perform a GET request.
      #
      # url     - The URL path to request.
      # params  - Optional Hash of query parameters (default: {}).
      # headers - Optional Hash of additional HTTP headers (default: {}).
      #
      # Returns the Faraday::Response on success.
      # Raises D4H::API::Error on non-2xx status.
      def get_request(url, params: {}, headers: {})
        handle_response(client.connection.get(url, params, default_headers.merge(headers)))
      end

      # Public: Perform a POST request.
      #
      # url     - The URL path to request.
      # body    - The Hash request body to send.
      # headers - Optional Hash of additional HTTP headers (default: {}).
      #
      # Returns the Faraday::Response on success.
      # Raises D4H::API::Error on non-2xx status.
      def post_request(url, body:, headers: {})
        handle_response(client.connection.post(url, body, default_headers.merge(headers)))
      end

      # Public: Perform a PUT request.
      #
      # Used by DocumentResource, which requires PUT for updates per the D4H API.
      #
      # url     - The URL path to request.
      # body    - The Hash request body to send.
      # headers - Optional Hash of additional HTTP headers (default: {}).
      #
      # Returns the Faraday::Response on success.
      # Raises D4H::API::Error on non-2xx status.
      def put_request(url, body:, headers: {})
        handle_response(client.connection.put(url, body, default_headers.merge(headers)))
      end

      # Public: Perform a PATCH request.
      #
      # Used by most resources for updates.
      #
      # url     - The URL path to request.
      # body    - The Hash request body to send (default: {}).
      # headers - Optional Hash of additional HTTP headers (default: {}).
      #
      # Returns the Faraday::Response on success.
      # Raises D4H::API::Error on non-2xx status.
      def patch_request(url, body: {}, headers: {})
        handle_response(client.connection.patch(url, body, default_headers.merge(headers)))
      end

      # Public: Perform a DELETE request.
      #
      # url     - The URL path to request.
      # params  - Optional Hash of query parameters (default: {}).
      # headers - Optional Hash of additional HTTP headers (default: {}).
      #
      # Returns the Faraday::Response on success.
      # Raises D4H::API::Error on non-2xx status.
      def delete_request(url, params: {}, headers: {})
        handle_response(client.connection.delete(url, params, default_headers.merge(headers)))
      end

      # Internal: Returns the default Authorization header for all requests.
      def default_headers
        {Authorization: "Bearer #{client.api_key}"}
      end

      # Internal: Check the HTTP response status and raise on errors.
      #
      # response - A Faraday::Response object.
      #
      # Returns the response if status is 2xx.
      # Raises D4H::API::RetriableError for transient errors (429, 5xx) after
      # all retry attempts have been exhausted by the Faraday retry middleware.
      # Raises D4H::API::Error for all other non-2xx responses.
      def handle_response(response)
        return response if (200..299).cover?(response.status)

        body = response.body || {}
        message = [body["title"], body["detail"], body["error"], body["message"]].compact.uniq.join(": ")

        raise RetriableError, message if Client::RETRIABLE_STATUSES.include?(response.status)

        raise Error, message
      end

      private

      # Internal: Fetch all pages of a list endpoint and return a single Collection.
      #
      # Iterates through pages starting at page 0, accumulating results until
      # all records are fetched (based on totalSize) or the API returns an
      # empty page.
      #
      # params      - A Hash of query parameters. :size defaults to 250.
      # model_class - The Model subclass to wrap results in (e.g. Member, Tag).
      #
      # Returns a Collection containing all results across all pages.
      def paginate_all(params, model_class:)
        params[:size] ||= 250
        all_results = []
        page = params.fetch(:page, 0)

        loop do
          response = get_request(resource_url, params: params.merge(page: page)).body
          results = response["results"] || []
          all_results.concat(results)
          break if all_results.size >= response["totalSize"] || results.empty?

          page += 1
        end

        Collection.new(
          {"results" => all_results, "page" => 0, "pageSize" => all_results.size, "totalSize" => all_results.size},
          model_class: model_class,
        )
      end
    end
  end
end
