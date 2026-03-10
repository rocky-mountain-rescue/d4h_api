# frozen_string_literal: true

module D4H
  module API
    # Public: Raised when the D4H API returns a non-2xx HTTP response.
    #
    # The message is built from the response body's "error" and "message"
    # fields, joined with a colon.
    #
    # Examples
    #
    #   begin
    #     client.equipment.show(id: 999_999)
    #   rescue D4H::API::Error => e
    #     e.message  # => "Not Found: Equipment not found"
    #   end
    class Error < StandardError
    end

    # Public: Raised for transient HTTP errors that are safe to retry.
    #
    # Triggered by 429 (rate limited) and 5xx (server error) responses.
    # The Faraday retry middleware catches this exception and retries
    # with exponential backoff.
    #
    # If all retries are exhausted the exception propagates to the caller,
    # so it can still be rescued like any other D4H::API::Error.
    class RetriableError < Error
    end
  end
end
