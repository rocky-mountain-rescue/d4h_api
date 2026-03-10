# frozen_string_literal: true

require "test_helper"

class PaginationTest < Minitest::Test
  include StubHelpers

  def setup
    @client = build_client
  end

  def teardown
    @stubs.verify_stubbed_calls
  end

  def test_list_all_single_page
    @stubs.get("v3/team/42/events") do |_env|
      json_response(list_body([{"id" => 1}, {"id" => 2}, {"id" => 3}], total_size: 3))
    end

    collection = @client.event.list_all

    assert_equal 3, collection.total_size
    assert_equal [1, 2, 3], collection.map(&:id)
  end

  def test_list_all_multiple_pages
    call_count = 0

    @stubs.get("v3/team/42/members") do |env|
      page = env.params["page"].to_i
      call_count += 1

      case page
      when 0
        json_response(list_body(
          (1..3).map { |i| {"id" => i, "name" => "Member #{i}"} },
          total_size: 7,
        ))
      when 1
        json_response(list_body(
          (4..6).map { |i| {"id" => i, "name" => "Member #{i}"} },
          total_size: 7,
        ))
      when 2
        json_response(list_body(
          [{"id" => 7, "name" => "Member 7"}],
          total_size: 7,
        ))
      end
    end

    collection = @client.member.list_all(size: 3)

    assert_equal 3, call_count
    assert_equal 7, collection.total_size
    assert_equal (1..7).to_a, collection.map(&:id)
  end

  def test_list_all_empty
    @stubs.get("v3/team/42/incidents") do |_env|
      json_response(empty_list_body)
    end

    collection = @client.incident.list_all

    assert_empty collection.results
    assert_equal 0, collection.total_size
  end

  def test_list_all_exact_page_boundary
    call_count = 0

    @stubs.get("v3/team/42/tags") do |env|
      page = env.params["page"].to_i
      call_count += 1

      case page
      when 0
        json_response(list_body([{"id" => 1}, {"id" => 2}], total_size: 4))
      when 1
        json_response(list_body([{"id" => 3}, {"id" => 4}], total_size: 4))
      end
    end

    collection = @client.tag.list_all(size: 2)

    assert_equal 2, call_count
    assert_equal 4, collection.total_size
    assert_equal [1, 2, 3, 4], collection.map(&:id)
  end

  def test_list_all_default_size_is_250
    @stubs.get("v3/team/42/equipment") do |env|
      assert_equal "250", env.params["size"]
      json_response(empty_list_body)
    end

    @client.equipment.list_all
  end

  def test_list_all_preserves_filters
    @stubs.get("v3/team/42/members") do |env|
      assert_equal "OPERATIONAL", env.params["status"]
      assert_equal "250", env.params["size"]
      json_response(list_body([{"id" => 1}]))
    end

    @client.member.list_all(status: "OPERATIONAL")
  end

  def test_list_all_custom_size
    @stubs.get("v3/team/42/roles") do |env|
      assert_equal "50", env.params["size"]
      json_response(list_body([{"id" => 1}]))
    end

    @client.role.list_all(size: 50)
  end
end
