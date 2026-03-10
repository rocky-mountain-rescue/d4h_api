# frozen_string_literal: true

require "test_helper"

class SpecialResourceTest < Minitest::Test
  include StubHelpers

  def setup
    @client = build_client
  end

  def teardown
    @stubs.verify_stubbed_calls
  end

  # -- team (show only, with id:) --

  def test_team_show
    @stubs.get("v3/team/42/teams/42") do |_env|
      json_response({
        "id" => 42,
        "title" => "Rocky Mountain Rescue",
        "timezone" => "America/Denver",
        "country" => "US",
        "memberCounts" => {"total" => 90, "operational" => 85},
      })
    end

    team = @client.team.show(id: 42)

    assert_kind_of D4H::API::Team, team
    assert_equal "Rocky Mountain Rescue", team.title
    assert_equal "America/Denver", team.timezone
    assert_equal 90, team.memberCounts.total
    assert_equal 85, team.memberCounts.operational
  end

  # -- organisation (show only, uses base_path/organisations/{id}) --

  def test_organisation_show
    @stubs.get("v3/team/42/organisations/5") do |_env|
      json_response({
        "id" => 5,
        "title" => "Colorado SAR",
        "resourceType" => "Organisation",
      })
    end

    org = @client.organisation.show(id: 5)

    assert_kind_of D4H::API::Organisation, org
    assert_equal "Colorado SAR", org.title
  end

  # -- whoami (show with no args) --

  def test_whoami_show
    @stubs.get("v3/team/42/whoami") do |_env|
      json_response({
        "id" => 1,
        "name" => "John Doe",
        "email" => "john@example.com",
        "resourceType" => "Member",
      })
    end

    me = @client.whoami.show

    assert_kind_of D4H::API::Whoami, me
    assert_equal "John Doe", me.name
    assert_equal "john@example.com", me.email
  end

  # -- member (list + update, no create or destroy) --

  def test_member_list
    @stubs.get("v3/team/42/members") do |_env|
      json_response(list_body([
        {"id" => 1, "name" => "Alice", "status" => "OPERATIONAL"},
        {"id" => 2, "name" => "Bob", "status" => "NON_OPERATIONAL"},
      ]))
    end

    collection = @client.member.list

    assert_equal 2, collection.results.size
    assert_equal "OPERATIONAL", collection.first.status
  end

  def test_member_update
    @stubs.patch("v3/team/42/members/1") do |_env|
      json_response({"id" => 1, "name" => "Alice Smith", "status" => "OPERATIONAL"})
    end

    member = @client.member.update(id: 1, name: "Alice Smith")

    assert_equal "Alice Smith", member.name
  end

  def test_member_does_not_respond_to_create
    refute_respond_to @client.member, :create
  end

  def test_member_does_not_respond_to_destroy
    refute_respond_to @client.member, :destroy
  end

  # -- event (list, show, create, update, no destroy) --

  def test_event_list
    @stubs.get("v3/team/42/events") do |_env|
      json_response(list_body([{"id" => 1, "reference" => "EVT-001"}]))
    end

    assert_equal "EVT-001", @client.event.list.first.reference
  end

  def test_event_show
    @stubs.get("v3/team/42/events/1") do |_env|
      json_response({"id" => 1, "reference" => "EVT-001", "description" => "Monthly drill"})
    end

    event = @client.event.show(id: 1)
    assert_equal "Monthly drill", event.description
  end

  def test_event_create
    @stubs.post("v3/team/42/events") do |_env|
      json_response({"id" => 10, "reference" => "EVT-010"})
    end

    event = @client.event.create({"reference" => "EVT-010", "startsAt" => "2026-03-09T08:00:00Z"})
    assert_equal 10, event.id
  end

  def test_event_update
    @stubs.patch("v3/team/42/events/1") do |_env|
      json_response({"id" => 1, "description" => "Updated drill"})
    end

    event = @client.event.update(id: 1, description: "Updated drill")
    assert_equal "Updated drill", event.description
  end

  def test_event_does_not_respond_to_destroy
    refute_respond_to @client.event, :destroy
  end

  # -- exercise (list, show, create, update, destroy) --

  def test_exercise_list
    @stubs.get("v3/team/42/exercises") do |_env|
      json_response(list_body([{"id" => 1, "reference" => "EX-001"}]))
    end

    assert_equal "EX-001", @client.exercise.list.first.reference
  end

  def test_exercise_create
    @stubs.post("v3/team/42/exercises") do |_env|
      json_response({"id" => 5, "reference" => "EX-005"})
    end

    ex = @client.exercise.create({"reference" => "EX-005"})
    assert_equal 5, ex.id
  end

  # -- incident (list, show, create, update, no destroy) --

  def test_incident_show
    @stubs.get("v3/team/42/incidents/7") do |_env|
      json_response({"id" => 7, "reference" => "INC-007", "description" => "Missing hiker"})
    end

    incident = @client.incident.show(id: 7)
    assert_equal "Missing hiker", incident.description
  end

  def test_incident_create
    @stubs.post("v3/team/42/incidents") do |_env|
      json_response({"id" => 8, "reference" => "INC-008"})
    end

    incident = @client.incident.create({"reference" => "INC-008"})
    assert_equal 8, incident.id
  end

  # -- attendance (list, show, create, no update or destroy) --

  def test_attendance_show
    @stubs.get("v3/team/42/attendance/100") do |_env|
      json_response({
        "id" => 100,
        "status" => "ATTENDING",
        "member" => {"id" => 1, "resourceType" => "Member"},
        "activity" => {"id" => 5, "resourceType" => "Event"},
      })
    end

    att = @client.attendance.show(id: 100)
    assert_equal "ATTENDING", att.status
    assert_equal 1, att.member.id
  end

  def test_attendance_create
    @stubs.post("v3/team/42/attendance") do |_env|
      json_response({"id" => 101, "status" => "ATTENDING"})
    end

    att = @client.attendance.create({"memberId" => 1, "activityId" => 5, "status" => "ATTENDING"})
    assert_equal 101, att.id
  end

  # -- document (uses PUT for update) --

  def test_document_list
    @stubs.get("v3/team/42/documents") do |_env|
      json_response(list_body([{"id" => 1, "title" => "SOP Manual"}]))
    end

    assert_equal "SOP Manual", @client.document.list.first.title
  end

  def test_document_update_uses_put
    @stubs.put("v3/team/42/documents/1") do |_env|
      json_response({"id" => 1, "title" => "Updated SOP"})
    end

    doc = @client.document.update(id: 1, title: "Updated SOP")
    assert_equal "Updated SOP", doc.title
  end

  def test_document_destroy
    @stubs.delete("v3/team/42/documents/1") do |_env|
      [200, {"Content-Type" => "application/json"}, ""]
    end

    @client.document.destroy(id: 1)
  end

  # -- custom_field (list, show, create, update, destroy) --

  def test_custom_field_show
    @stubs.get("v3/team/42/custom-fields/3") do |_env|
      json_response({"id" => 3, "title" => "Badge Number", "type" => "TEXT"})
    end

    cf = @client.custom_field.show(id: 3)
    assert_equal "Badge Number", cf.title
    assert_equal "TEXT", cf.type
  end

  def test_custom_field_update
    @stubs.patch("v3/team/42/custom-fields/3") do |_env|
      json_response({"id" => 3, "title" => "Employee Badge"})
    end

    cf = @client.custom_field.update(id: 3, title: "Employee Badge")
    assert_equal "Employee Badge", cf.title
  end

  def test_custom_field_destroy
    @stubs.delete("v3/team/42/custom-fields/3") do |_env|
      [200, {"Content-Type" => "application/json"}, ""]
    end

    @client.custom_field.destroy(id: 3)
  end

  # -- custom_field_for_entity (list, show) --

  def test_custom_field_for_entity_list
    @stubs.get("v3/team/42/custom-field-options") do |_env|
      json_response(list_body([{"id" => 1, "label" => "Option A"}]))
    end

    assert_equal "Option A", @client.custom_field_for_entity.list.first.label
  end

  def test_custom_field_for_entity_show
    @stubs.get("v3/team/42/custom-field-options/1") do |_env|
      json_response({"id" => 1, "label" => "Option A"})
    end

    opt = @client.custom_field_for_entity.show(id: 1)
    assert_equal "Option A", opt.label
  end

  # -- member_qualification_award (list, create, no show/update/destroy) --

  def test_member_qualification_award_list
    @stubs.get("v3/team/42/member-qualification-awards") do |_env|
      json_response(list_body([{"id" => 1, "memberId" => 10}]))
    end

    assert_equal 10, @client.member_qualification_award.list.first.memberId
  end

  def test_member_qualification_award_create
    @stubs.post("v3/team/42/member-qualification-awards") do |_env|
      json_response({"id" => 2, "memberId" => 10, "qualificationId" => 5})
    end

    award = @client.member_qualification_award.create({"memberId" => 10, "qualificationId" => 5})
    assert_equal 2, award.id
  end

  def test_member_qualification_award_does_not_respond_to_show
    refute_respond_to @client.member_qualification_award, :show
  end

  # -- equipment_inspection_result (list, show, update, destroy, no create) --

  def test_equipment_inspection_result_list
    @stubs.get("v3/team/42/equipment-inspection-results") do |_env|
      json_response(list_body([{"id" => 1, "status" => "PASS"}]))
    end

    assert_equal "PASS", @client.equipment_inspection_result.list.first.status
  end

  def test_equipment_inspection_result_update
    @stubs.patch("v3/team/42/equipment-inspection-results/1") do |_env|
      json_response({"id" => 1, "status" => "FAIL"})
    end

    result = @client.equipment_inspection_result.update(id: 1, status: "FAIL")
    assert_equal "FAIL", result.status
  end

  def test_equipment_inspection_result_destroy
    @stubs.delete("v3/team/42/equipment-inspection-results/1") do |_env|
      [200, {"Content-Type" => "application/json"}, ""]
    end

    @client.equipment_inspection_result.destroy(id: 1)
  end

  def test_equipment_inspection_result_does_not_respond_to_create
    refute_respond_to @client.equipment_inspection_result, :create
  end

  # -- organisation context --

  def test_resources_work_with_organisation_context
    client = build_client(context: "organisation", context_id: 99)

    @stubs.get("v3/organisation/99/members") do |_env|
      json_response(list_body([{"id" => 1, "name" => "Alice"}]))
    end

    collection = client.member.list
    assert_equal "Alice", collection.first.name
  end
end
