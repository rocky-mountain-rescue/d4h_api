# frozen_string_literal: true

require "test_helper"

class ReadOnlyResourceTest < Minitest::Test
  include StubHelpers

  def setup
    @client = build_client
  end

  def teardown
    @stubs.verify_stubbed_calls
  end

  # -- list-only resources --

  def test_customer_identifier_list
    @stubs.get("v3/team/42/customer-identifiers") do |_env|
      json_response(list_body([{"id" => 1, "value" => "CUST-001"}]))
    end

    collection = @client.customer_identifier.list
    assert_equal 1, collection.first.id
  end

  def test_member_custom_status_list
    @stubs.get("v3/team/42/member-custom-statuses") do |_env|
      json_response(list_body([{"id" => 1, "label" => "On Leave"}]))
    end

    collection = @client.member_custom_status.list
    assert_equal "On Leave", collection.first.label
  end

  def test_member_retired_reason_list
    @stubs.get("v3/team/42/member-retired-reasons") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Moved away"}]))
    end

    collection = @client.member_retired_reason.list
    assert_equal "Moved away", collection.first.title
  end

  def test_d4h_module_list
    @stubs.get("v3/team/42/modules") do |_env|
      json_response(list_body([{"id" => 1, "name" => "Equipment"}]))
    end

    collection = @client.d4h_module.list
    assert_equal "Equipment", collection.first.name
  end

  def test_d4h_task_list
    @stubs.get("v3/team/42/tasks") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Inventory check"}]))
    end

    collection = @client.d4h_task.list
    assert_equal "Inventory check", collection.first.title
  end

  def test_search_list
    @stubs.get("v3/team/42/search") do |_env|
      json_response(list_body([{"id" => 1, "resourceType" => "Member", "title" => "John"}]))
    end

    collection = @client.search.list
    assert_equal "Member", collection.first.resourceType
  end

  def test_incident_involved_metadata_list
    @stubs.get("v3/team/42/incident-involved-metadata") do |_env|
      json_response(list_body([{"id" => 1, "key" => "weather"}]))
    end

    collection = @client.incident_involved_metadata.list
    assert_equal 1, collection.first.id
  end

  # -- list + show resources --

  def test_role_list_and_show
    @stubs.get("v3/team/42/roles") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Team Leader"}]))
    end

    assert_equal "Team Leader", @client.role.list.first.title

    @stubs.get("v3/team/42/roles/1") do |_env|
      json_response({"id" => 1, "title" => "Team Leader"})
    end

    role = @client.role.show(id: 1)
    assert_equal "Team Leader", role.title
  end

  def test_duty_list_and_show
    @stubs.get("v3/team/42/duties") do |_env|
      json_response(list_body([{"id" => 1, "startsAt" => "2026-03-09T08:00:00Z"}]))
    end

    assert_equal 1, @client.duty.list.first.id

    @stubs.get("v3/team/42/duties/1") do |_env|
      json_response({"id" => 1, "startsAt" => "2026-03-09T08:00:00Z"})
    end

    duty = @client.duty.show(id: 1)
    assert_equal 1, duty.id
  end

  def test_animal_list_and_show
    @stubs.get("v3/team/42/animals") do |_env|
      json_response(list_body([{"id" => 1, "name" => "Rex"}]))
    end

    assert_equal "Rex", @client.animal.list.first.name

    @stubs.get("v3/team/42/animals/1") do |_env|
      json_response({"id" => 1, "name" => "Rex", "breed" => "German Shepherd"})
    end

    animal = @client.animal.show(id: 1)
    assert_equal "German Shepherd", animal.breed
  end

  def test_location_bookmark_list_and_show
    @stubs.get("v3/team/42/location-bookmarks") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Base Camp"}]))
    end

    assert_equal "Base Camp", @client.location_bookmark.list.first.title

    @stubs.get("v3/team/42/location-bookmarks/1") do |_env|
      json_response({"id" => 1, "title" => "Base Camp"})
    end

    bookmark = @client.location_bookmark.show(id: 1)
    assert_equal "Base Camp", bookmark.title
  end

  def test_equipment_location_list_and_show
    @stubs.get("v3/team/42/equipment-locations") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Truck 1"}]))
    end

    assert_equal "Truck 1", @client.equipment_location.list.first.title
  end

  def test_equipment_inspection_list_and_show
    @stubs.get("v3/team/42/equipment-inspections") do |_env|
      json_response(list_body([{"id" => 1, "status" => "PASS"}]))
    end

    assert_equal "PASS", @client.equipment_inspection.list.first.status

    @stubs.get("v3/team/42/equipment-inspections/1") do |_env|
      json_response({"id" => 1, "status" => "PASS"})
    end

    inspection = @client.equipment_inspection.show(id: 1)
    assert_equal "PASS", inspection.status
  end

  def test_health_safety_report_list_and_show
    @stubs.get("v3/team/42/health-safety-reports") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Near miss"}]))
    end

    assert_equal "Near miss", @client.health_safety_report.list.first.title
  end

  def test_member_qualification_list_and_show
    @stubs.get("v3/team/42/member-qualifications") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Wilderness First Responder"}]))
    end

    assert_equal "Wilderness First Responder", @client.member_qualification.list.first.title
  end

  def test_handler_qualification_list_and_show
    @stubs.get("v3/team/42/handler-qualifications") do |_env|
      json_response(list_body([{"id" => 1, "title" => "K9 Certification"}]))
    end

    assert_equal "K9 Certification", @client.handler_qualification.list.first.title
  end

  def test_incident_involved_person_list_and_show
    @stubs.get("v3/team/42/incident-involved-persons") do |_env|
      json_response(list_body([{"id" => 1, "name" => "Jane Doe"}]))
    end

    assert_equal "Jane Doe", @client.incident_involved_person.list.first.name
  end

  def test_incident_involved_injury_list_and_show
    @stubs.get("v3/team/42/incident-involved-injuries") do |_env|
      json_response(list_body([{"id" => 1, "type" => "Fracture"}]))
    end

    assert_equal "Fracture", @client.incident_involved_injury.list.first.type
  end

  def test_resource_bundle_list_and_show
    @stubs.get("v3/team/42/resource-bundles") do |_env|
      json_response(list_body([{"id" => 1, "title" => "Rope Kit"}]))
    end

    assert_equal "Rope Kit", @client.resource_bundle.list.first.title
  end

  # -- list-only resources have list_all --

  def test_list_only_resources_support_list_all
    @stubs.get("v3/team/42/customer-identifiers") do |_env|
      json_response(list_body([{"id" => 1}]))
    end

    collection = @client.customer_identifier.list_all
    assert_kind_of D4H::API::Collection, collection
    assert_equal 1, collection.total_size
  end

  # -- list+show resources have list_all --

  def test_list_show_resources_support_list_all
    @stubs.get("v3/team/42/roles") do |_env|
      json_response(list_body([{"id" => 1}, {"id" => 2}]))
    end

    collection = @client.role.list_all
    assert_equal 2, collection.total_size
  end
end
