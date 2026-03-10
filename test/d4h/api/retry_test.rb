# frozen_string_literal: true

require "test_helper"

class RetryTest < Minitest::Test
  include StubHelpers

  def build_retry_client(max_retries: 2)
    @stubs = Faraday::Adapter::Test::Stubs.new(strict_mode: false)
    D4H::API::Client.new(
      api_key: "test-key",
      context: "team",
      context_id: 42,
      adapter: [:test, @stubs],
      max_retries: max_retries,
      retry_interval: 0,
    )
  end

  def test_retries_on_429_then_succeeds
    call_count = 0
    client = build_retry_client(max_retries: 2)

    @stubs.get("v3/team/42/roles") do |_env|
      call_count += 1
      if call_count < 2
        json_response({"error" => "Too Many Requests"}, status: 429)
      else
        json_response(list_body([{"id" => 1, "title" => "Leader"}]))
      end
    end

    collection = client.role.list

    assert_equal 2, call_count
    assert_equal "Leader", collection.first.title
  end

  def test_retries_on_500_then_succeeds
    call_count = 0
    client = build_retry_client(max_retries: 2)

    @stubs.get("v3/team/42/tags") do |_env|
      call_count += 1
      if call_count < 2
        json_response({"error" => "Internal Server Error"}, status: 500)
      else
        json_response(list_body([{"id" => 1, "title" => "SAR"}]))
      end
    end

    collection = client.tag.list

    assert_equal 2, call_count
    assert_equal "SAR", collection.first.title
  end

  def test_retries_on_503_then_succeeds
    call_count = 0
    client = build_retry_client(max_retries: 3)

    @stubs.get("v3/team/42/members") do |_env|
      call_count += 1
      if call_count <= 2
        json_response({"error" => "Service Unavailable"}, status: 503)
      else
        json_response(list_body([{"id" => 1, "name" => "Alice"}]))
      end
    end

    collection = client.member.list

    assert_equal 3, call_count
    assert_equal "Alice", collection.first.name
  end

  def test_raises_retriable_error_after_all_retries_exhausted
    client = build_retry_client(max_retries: 2)

    @stubs.get("v3/team/42/members") do |_env|
      json_response({"error" => "Too Many Requests", "message" => "Rate limited"}, status: 429)
    end

    error = assert_raises(D4H::API::RetriableError) { client.member.list }
    assert_includes error.message, "Rate limited"
  end

  def test_does_not_retry_on_400
    call_count = 0
    client = build_retry_client(max_retries: 3)

    @stubs.get("v3/team/42/members") do |_env|
      call_count += 1
      json_response({"error" => "Bad Request"}, status: 400)
    end

    assert_raises(D4H::API::Error) { client.member.list }
    assert_equal 1, call_count
  end

  def test_does_not_retry_on_404
    call_count = 0
    client = build_retry_client(max_retries: 3)

    @stubs.get("v3/team/42/tags/999") do |_env|
      call_count += 1
      json_response({"error" => "Not Found"}, status: 404)
    end

    assert_raises(D4H::API::Error) { client.tag.show(id: 999) }
    assert_equal 1, call_count
  end

  def test_no_retries_when_max_retries_is_zero
    call_count = 0
    client = build_retry_client(max_retries: 0)

    @stubs.get("v3/team/42/members") do |_env|
      call_count += 1
      json_response({"error" => "Too Many Requests"}, status: 429)
    end

    assert_raises(D4H::API::RetriableError) { client.member.list }
    assert_equal 1, call_count
  end

  def test_retries_post_requests
    call_count = 0
    client = build_retry_client(max_retries: 2)

    @stubs.post("v3/team/42/tags") do |_env|
      call_count += 1
      if call_count < 2
        json_response({"error" => "Service Unavailable"}, status: 503)
      else
        json_response({"id" => 1, "title" => "New Tag"})
      end
    end

    tag = client.tag.create({"title" => "New Tag"})

    assert_equal 2, call_count
    assert_equal "New Tag", tag.title
  end

  def test_retries_patch_requests
    call_count = 0
    client = build_retry_client(max_retries: 2)

    @stubs.patch("v3/team/42/members/1") do |_env|
      call_count += 1
      if call_count < 2
        json_response({"error" => "Too Many Requests"}, status: 429)
      else
        json_response({"id" => 1, "name" => "Updated"})
      end
    end

    member = client.member.update(id: 1, name: "Updated")

    assert_equal 2, call_count
    assert_equal "Updated", member.name
  end
end
