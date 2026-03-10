# frozen_string_literal: true

require "test_helper"

class ClientTest < Minitest::Test
  def test_initializes_with_required_params
    client = D4H::API::Client.new(api_key: "abc123", context_id: 7)

    assert_equal "abc123", client.api_key
    assert_equal 7, client.context_id
    assert_equal "team", client.context
  end

  def test_defaults_context_to_team
    client = D4H::API::Client.new(api_key: "key", context_id: 1)

    assert_equal "team", client.context
  end

  def test_accepts_custom_context
    client = D4H::API::Client.new(api_key: "key", context: "organisation", context_id: 5)

    assert_equal "organisation", client.context
  end

  def test_base_path_with_team_context
    client = D4H::API::Client.new(api_key: "key", context_id: 42)

    assert_equal "v3/team/42", client.base_path
  end

  def test_base_path_with_organisation_context
    client = D4H::API::Client.new(api_key: "key", context: "organisation", context_id: 99)

    assert_equal "v3/organisation/99", client.base_path
  end

  def test_inspect_hides_api_key
    client = D4H::API::Client.new(api_key: "secret-token", context_id: 1)

    assert_equal "#<D4H::Client>", client.inspect
    refute_includes client.inspect, "secret-token"
  end

  def test_defaults_base_url
    client = D4H::API::Client.new(api_key: "key", context_id: 1)

    assert_equal "https://api.team-manager.us.d4h.com", client.base_url
  end

  def test_accepts_custom_base_url
    client = D4H::API::Client.new(
      api_key: "key",
      context_id: 1,
      base_url: "https://api.team-manager.eu.d4h.com",
    )

    assert_equal "https://api.team-manager.eu.d4h.com", client.base_url
  end

  def test_connection_returns_faraday_connection
    client = D4H::API::Client.new(api_key: "key", context_id: 1)

    assert_kind_of Faraday::Connection, client.connection
  end

  def test_connection_is_memoized
    client = D4H::API::Client.new(api_key: "key", context_id: 1)

    assert_same client.connection, client.connection
  end

  # -- resource accessors return correct types --

  def test_resource_accessors
    client = D4H::API::Client.new(api_key: "key", context_id: 1)

    {
      animal: D4H::API::AnimalResource,
      animal_group: D4H::API::AnimalGroupResource,
      attendance: D4H::API::AttendanceResource,
      custom_field: D4H::API::CustomFieldResource,
      document: D4H::API::DocumentResource,
      duty: D4H::API::DutyResource,
      equipment: D4H::API::EquipmentResource,
      event: D4H::API::EventResource,
      exercise: D4H::API::ExerciseResource,
      handler_group: D4H::API::HandlerGroupResource,
      health_safety_category: D4H::API::HealthSafetyCategoryResource,
      incident: D4H::API::IncidentResource,
      member: D4H::API::MemberResource,
      member_group: D4H::API::MemberGroupResource,
      organisation: D4H::API::OrganisationResource,
      repair: D4H::API::RepairResource,
      role: D4H::API::RoleResource,
      tag: D4H::API::TagResource,
      team: D4H::API::TeamResource,
      whiteboard: D4H::API::WhiteboardResource,
      whoami: D4H::API::WhoamiResource,
    }.each do |method, klass|
      assert_kind_of klass, client.send(method), "client.#{method} should return #{klass}"
    end
  end
end
