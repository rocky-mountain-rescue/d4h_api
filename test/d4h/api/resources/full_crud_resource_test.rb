# frozen_string_literal: true

require "test_helper"

class FullCrudResourceTest < Minitest::Test
  include StubHelpers

  def setup
    @client = build_client
  end

  def teardown
    @stubs.verify_stubbed_calls
  end

  # -- list --

  def test_list_returns_collection
    @stubs.get("v3/team/42/tags") do |_env|
      json_response(list_body([
        {"id" => 1, "title" => "SAR"},
        {"id" => 2, "title" => "Training"},
      ]))
    end

    collection = @client.tag.list

    assert_kind_of D4H::API::Collection, collection
    assert_equal 2, collection.results.size
    assert_equal "SAR", collection.first.title
  end

  def test_list_passes_query_params
    @stubs.get("v3/team/42/equipment") do |env|
      assert_equal "true", env.params["is_critical"]
      assert_equal "10", env.params["size"]
      json_response(list_body([{"id" => 1, "ref" => "E001"}]))
    end

    @client.equipment.list(is_critical: true, size: 10)
  end

  # -- show --

  def test_show_returns_model
    @stubs.get("v3/team/42/tags/5") do |_env|
      json_response({"id" => 5, "title" => "Avalanche"})
    end

    tag = @client.tag.show(id: 5)

    assert_kind_of D4H::API::Tag, tag
    assert_equal 5, tag.id
    assert_equal "Avalanche", tag.title
  end

  def test_show_with_nested_data
    @stubs.get("v3/team/42/equipment/10") do |_env|
      json_response({
        "id" => 10,
        "ref" => "E010",
        "owner" => {"id" => 42, "resourceType" => "Team"},
        "brand" => {"id" => 3, "title" => "Petzl"},
      })
    end

    item = @client.equipment.show(id: 10)

    assert_equal "E010", item.ref
    assert_equal "Team", item.owner.resourceType
    assert_equal "Petzl", item.brand.title
  end

  # -- create --

  def test_create_returns_model
    @stubs.post("v3/team/42/tags") do |_env|
      json_response({"id" => 10, "title" => "High Angle"})
    end

    tag = @client.tag.create({"title" => "High Angle"})

    assert_kind_of D4H::API::Tag, tag
    assert_equal 10, tag.id
    assert_equal "High Angle", tag.title
  end

  def test_create_equipment
    @stubs.post("v3/team/42/equipment") do |_env|
      json_response({"id" => 100, "ref" => "E100", "resourceType" => "Equipment"})
    end

    item = @client.equipment.create({"ref" => "E100", "categoryId" => 1, "kindId" => 2})

    assert_kind_of D4H::API::Equipment, item
    assert_equal "E100", item.ref
  end

  # -- update (PATCH) --

  def test_update_returns_model
    @stubs.patch("v3/team/42/tags/5") do |_env|
      json_response({"id" => 5, "title" => "Updated Tag"})
    end

    tag = @client.tag.update(id: 5, title: "Updated Tag")

    assert_equal "Updated Tag", tag.title
  end

  # -- destroy --

  def test_destroy_succeeds
    @stubs.delete("v3/team/42/tags/5") do |_env|
      [200, {"Content-Type" => "application/json"}, ""]
    end

    @client.tag.destroy(id: 5)
  end

  # -- test full CRUD on multiple resource types --

  def test_repair_full_crud
    # list
    @stubs.get("v3/team/42/repairs") do |_env|
      json_response(list_body([{"id" => 1, "description" => "Fix harness"}]))
    end

    collection = @client.repair.list
    assert_equal 1, collection.first.id

    # show
    @stubs.get("v3/team/42/repairs/1") do |_env|
      json_response({"id" => 1, "description" => "Fix harness"})
    end

    repair = @client.repair.show(id: 1)
    assert_equal "Fix harness", repair.description

    # create
    @stubs.post("v3/team/42/repairs") do |_env|
      json_response({"id" => 2, "description" => "Replace rope"})
    end

    repair = @client.repair.create({"description" => "Replace rope"})
    assert_equal 2, repair.id

    # update
    @stubs.patch("v3/team/42/repairs/2") do |_env|
      json_response({"id" => 2, "description" => "Replace rope - done"})
    end

    repair = @client.repair.update(id: 2, description: "Replace rope - done")
    assert_equal "Replace rope - done", repair.description

    # destroy
    @stubs.delete("v3/team/42/repairs/2") do |_env|
      [200, {"Content-Type" => "application/json"}, ""]
    end

    @client.repair.destroy(id: 2)
  end

  def test_whiteboard_crud
    @stubs.get("v3/team/42/whiteboard") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Briefing"}]))
    end

    collection = @client.whiteboard.list
    assert_equal "Briefing", collection.first.title

    @stubs.post("v3/team/42/whiteboard") do |_env|
      json_response({"id" => 2, "title" => "New Note"})
    end

    note = @client.whiteboard.create({"title" => "New Note"})
    assert_equal 2, note.id
  end

  def test_animal_group_crud
    @stubs.get("v3/team/42/animal-groups") do |_env|
      json_response(list_body([{"id" => 1, "title" => "K9 Unit"}]))
    end

    collection = @client.animal_group.list
    assert_equal "K9 Unit", collection.first.title

    @stubs.post("v3/team/42/animal-groups") do |_env|
      json_response({"id" => 2, "title" => "Tracking Dogs"})
    end

    group = @client.animal_group.create({"title" => "Tracking Dogs"})
    assert_equal "Tracking Dogs", group.title
  end

  def test_member_group_crud
    @stubs.get("v3/team/42/member-groups") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Alpha Team"}]))
    end

    assert_equal "Alpha Team", @client.member_group.list.first.title

    @stubs.delete("v3/team/42/member-groups/1") do |_env|
      [200, {"Content-Type" => "application/json"}, ""]
    end

    @client.member_group.destroy(id: 1)
  end

  def test_health_safety_category_crud
    @stubs.get("v3/team/42/health-safety-categories") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Slip/Fall"}]))
    end

    assert_equal "Slip/Fall", @client.health_safety_category.list.first.title
  end

  def test_equipment_brand_crud
    @stubs.post("v3/team/42/equipment-brands") do |_env|
      json_response({"id" => 1, "title" => "Black Diamond"})
    end

    brand = @client.equipment_brand.create({"title" => "Black Diamond"})
    assert_equal "Black Diamond", brand.title
  end
end
