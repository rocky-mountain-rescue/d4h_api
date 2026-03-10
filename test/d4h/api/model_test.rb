# frozen_string_literal: true

require "test_helper"

class ModelTest < Minitest::Test
  def test_exposes_top_level_attributes
    model = D4H::API::Model.new({"id" => 1, "name" => "Test"})

    assert_equal 1, model.id
    assert_equal "Test", model.name
  end

  def test_converts_nested_hashes_to_ostruct
    model = D4H::API::Model.new({
      "id" => 1,
      "owner" => {"id" => 5, "resourceType" => "Team"},
    })

    assert_equal 5, model.owner.id
    assert_equal "Team", model.owner.resourceType
  end

  def test_converts_deeply_nested_hashes
    model = D4H::API::Model.new({
      "location" => {
        "address" => {"street" => "123 Main", "city" => "Denver"},
      },
    })

    assert_equal "123 Main", model.location.address.street
    assert_equal "Denver", model.location.address.city
  end

  def test_converts_arrays_of_hashes
    model = D4H::API::Model.new({
      "tags" => [
        {"id" => 1, "label" => "SAR"},
        {"id" => 2, "label" => "Training"},
      ],
    })

    assert_equal 2, model.tags.size
    assert_equal "SAR", model.tags.first.label
    assert_equal "Training", model.tags.last.label
  end

  def test_handles_primitive_arrays
    model = D4H::API::Model.new({"ids" => [1, 2, 3]})

    assert_equal [1, 2, 3], model.ids
  end

  def test_handles_nil_values
    model = D4H::API::Model.new({"id" => 1, "deletedAt" => nil})

    assert_nil model.deletedAt
  end

  def test_preserves_raw_json
    attrs = {"id" => 1, "name" => "Test", "nested" => {"key" => "val"}}
    model = D4H::API::Model.new(attrs)

    assert_equal attrs, model.to_json
  end

  def test_returns_nil_for_missing_attributes
    model = D4H::API::Model.new({"id" => 1})

    assert_nil model.nonexistent
  end

  def test_mixed_nesting_with_arrays_and_hashes
    model = D4H::API::Model.new({
      "customFieldValues" => [
        {
          "customField" => {"id" => 1, "type" => "NUMBER"},
          "value" => "123.45",
        },
      ],
    })

    assert_equal 1, model.customFieldValues.first.customField.id
    assert_equal "123.45", model.customFieldValues.first.value
  end
end
