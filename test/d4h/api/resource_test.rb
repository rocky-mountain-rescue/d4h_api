# frozen_string_literal: true

require "test_helper"

class ResourceTest < Minitest::Test
  include StubHelpers

  def setup
    @client = build_client
  end

  def teardown
    @stubs.verify_stubbed_calls
  end

  # -- authentication --

  def test_sends_bearer_token_header
    @stubs.get("v3/team/42/members") do |env|
      assert_equal "Bearer test-key", env.request_headers["Authorization"]
      json_response(list_body([]))
    end

    @client.member.list
  end

  # -- error handling --

  def test_raises_error_on_400
    @stubs.get("v3/team/42/members") do |_env|
      json_response({"error" => "Bad Request", "message" => "Invalid params"}, status: 400)
    end

    error = assert_raises(D4H::API::Error) { @client.member.list }
    assert_includes error.message, "Bad Request"
    assert_includes error.message, "Invalid params"
  end

  def test_raises_error_on_401
    @stubs.get("v3/team/42/members") do |_env|
      json_response({"error" => "Unauthorized", "message" => "Invalid token"}, status: 401)
    end

    error = assert_raises(D4H::API::Error) { @client.member.list }
    assert_includes error.message, "Unauthorized"
  end

  def test_raises_error_on_403
    @stubs.get("v3/team/42/members") do |_env|
      json_response({"error" => "Forbidden", "message" => "Insufficient permissions"}, status: 403)
    end

    assert_raises(D4H::API::Error) { @client.member.list }
  end

  def test_raises_error_on_404
    @stubs.patch("v3/team/42/members/999") do |_env|
      json_response({"error" => "Not Found", "message" => "Member not found"}, status: 404)
    end

    error = assert_raises(D4H::API::Error) { @client.member.update(id: 999, name: "x") }
    assert_includes error.message, "Not Found"
  end

  def test_raises_retriable_error_on_429
    @stubs.get("v3/team/42/members") do |_env|
      json_response({"error" => "Too Many Requests", "message" => "Rate limit exceeded"}, status: 429)
    end

    error = assert_raises(D4H::API::RetriableError) { @client.member.list }
    assert_kind_of D4H::API::Error, error
    assert_includes error.message, "Rate limit exceeded"
  end

  def test_raises_retriable_error_on_500
    @stubs.get("v3/team/42/members") do |_env|
      json_response({"error" => "Internal Server Error", "message" => "Something broke"}, status: 500)
    end

    error = assert_raises(D4H::API::RetriableError) { @client.member.list }
    assert_includes error.message, "Something broke"
  end

  def test_raises_retriable_error_on_502
    @stubs.get("v3/team/42/members") do |_env|
      json_response({}, status: 502)
    end

    error = assert_raises(D4H::API::RetriableError) { @client.member.list }
    assert_equal "", error.message
  end

  def test_raises_retriable_error_on_503
    @stubs.get("v3/team/42/members") do |_env|
      json_response({"error" => "Service Unavailable"}, status: 503)
    end

    assert_raises(D4H::API::RetriableError) { @client.member.list }
  end

  def test_non_retriable_errors_are_plain_error
    @stubs.get("v3/team/42/members") do |_env|
      json_response({"error" => "Forbidden"}, status: 403)
    end

    error = assert_raises(D4H::API::Error) { @client.member.list }
    refute_kind_of D4H::API::RetriableError, error
  end

  def test_retriable_error_is_subclass_of_error
    assert D4H::API::RetriableError < D4H::API::Error
  end

  def test_success_on_2xx_statuses
    @stubs.get("v3/team/42/roles") do |_env|
      json_response(list_body([{"id" => 1}]))
    end

    collection = @client.role.list
    assert_equal 1, collection.results.size
  end

  # -- resource_url --

  def test_resource_url_builds_correct_path
    resource = @client.tag
    assert_equal "v3/team/42/tags", resource.resource_url
  end

  def test_resource_url_with_organisation_context
    client = build_client(context: "organisation", context_id: 10)
    resource = client.equipment

    assert_equal "v3/organisation/10/equipment", resource.resource_url
  end
end
