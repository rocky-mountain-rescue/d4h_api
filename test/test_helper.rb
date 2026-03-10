# frozen_string_literal: true

require "bundler/setup"

require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)

require "d4h"
require "faraday"
require "json"

module StubHelpers
  def build_client(context_id: 42, context: "team", max_retries: 0)
    @stubs = Faraday::Adapter::Test::Stubs.new
    D4H::API::Client.new(
      api_key: "test-key",
      context: context,
      context_id: context_id,
      adapter: [:test, @stubs],
      max_retries: max_retries,
    )
  end

  def json_response(body, status: 200)
    [status, {"Content-Type" => "application/json"}, JSON.generate(body)]
  end

  def list_body(results, page: 0, page_size: 25, total_size: nil)
    {
      "results" => results,
      "page" => page,
      "pageSize" => page_size,
      "totalSize" => total_size || results.size,
    }
  end

  def empty_list_body
    list_body([], total_size: 0)
  end
end
