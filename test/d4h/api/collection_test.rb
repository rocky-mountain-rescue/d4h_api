# frozen_string_literal: true

require "test_helper"

class CollectionTest < Minitest::Test
  def test_parses_results_into_models
    body = {
      "results" => [{"id" => 1, "name" => "Alice"}, {"id" => 2, "name" => "Bob"}],
      "page" => 0,
      "pageSize" => 2,
      "totalSize" => 2,
    }

    collection = D4H::API::Collection.new(body, model_class: D4H::API::Member)

    assert_equal 2, collection.results.size
    assert_kind_of D4H::API::Member, collection.results.first
    assert_equal 1, collection.results.first.id
    assert_equal "Bob", collection.results.last.name
  end

  def test_pagination_metadata
    body = {
      "results" => [{"id" => 1}],
      "page" => 2,
      "pageSize" => 25,
      "totalSize" => 75,
    }

    collection = D4H::API::Collection.new(body, model_class: D4H::API::Member)

    assert_equal 2, collection.page
    assert_equal 25, collection.page_size
    assert_equal 75, collection.total_size
  end

  def test_enumerable_map
    body = {
      "results" => [{"id" => 1, "name" => "Alice"}, {"id" => 2, "name" => "Bob"}],
      "page" => 0,
      "pageSize" => 2,
      "totalSize" => 2,
    }

    collection = D4H::API::Collection.new(body, model_class: D4H::API::Member)

    assert_equal ["Alice", "Bob"], collection.map(&:name)
  end

  def test_enumerable_first
    body = {
      "results" => [{"id" => 1}, {"id" => 2}],
      "page" => 0,
      "pageSize" => 2,
      "totalSize" => 2,
    }

    collection = D4H::API::Collection.new(body, model_class: D4H::API::Member)

    assert_equal 1, collection.first.id
  end

  def test_enumerable_select
    body = {
      "results" => [{"id" => 1, "status" => "ATTENDING"}, {"id" => 2, "status" => "ABSENT"}],
      "page" => 0,
      "pageSize" => 2,
      "totalSize" => 2,
    }

    collection = D4H::API::Collection.new(body, model_class: D4H::API::Attendance)
    attending = collection.select { |a| a.status == "ATTENDING" }

    assert_equal 1, attending.size
  end

  def test_enumerable_count
    body = {
      "results" => [{"id" => 1}, {"id" => 2}, {"id" => 3}],
      "page" => 0,
      "pageSize" => 3,
      "totalSize" => 3,
    }

    collection = D4H::API::Collection.new(body, model_class: D4H::API::Tag)

    assert_equal 3, collection.count
  end

  def test_empty_results
    body = {
      "results" => [],
      "page" => 0,
      "pageSize" => 25,
      "totalSize" => 0,
    }

    collection = D4H::API::Collection.new(body, model_class: D4H::API::Member)

    assert_empty collection.results
    assert_equal 0, collection.total_size
    assert_equal 0, collection.count
  end

  def test_preserves_raw_json
    body = {
      "results" => [{"id" => 1}],
      "page" => 0,
      "pageSize" => 1,
      "totalSize" => 1,
    }

    collection = D4H::API::Collection.new(body, model_class: D4H::API::Member)

    assert_equal body, collection.to_json
  end

  def test_handles_nil_results_key
    body = {"page" => 0, "pageSize" => 25, "totalSize" => 0}

    collection = D4H::API::Collection.new(body, model_class: D4H::API::Member)

    assert_empty collection.results
  end

  def test_works_with_different_model_classes
    body = {
      "results" => [{"id" => 1, "title" => "Rescue Rope"}],
      "page" => 0,
      "pageSize" => 1,
      "totalSize" => 1,
    }

    collection = D4H::API::Collection.new(body, model_class: D4H::API::Equipment)

    assert_kind_of D4H::API::Equipment, collection.first
    assert_equal "Rescue Rope", collection.first.title
  end
end
