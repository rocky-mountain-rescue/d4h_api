# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.then do |loader|
  loader.inflector.inflect("d4h" => "D4H")
  loader.inflector.inflect("api" => "API")
  loader.setup
end

# Main namespace.
module D4H
  module API
    autoload :Client, "d4h/api/client"
    autoload :Error, "d4h/api/error"
    autoload :Model, "d4h/api/model"
    autoload :Resource, "d4h/api/resource"

    autoload :Attendance, "d4h/api/models/attendance"
    autoload :AttendanceResource, "d4h/api/resources/attendance_resource"

    autoload :CustomField, "d4h/api/models/custom_field"
    autoload :CustomFieldResource, "d4h/api/resources/custom_field_resource"

    autoload :CustomFieldForEntity, "d4h/api/models/custom_field_for_entity"
    autoload :CustomFieldForEntityResource, "d4h/api/resources/custom_field_for_entity_resource"

    autoload :Event, "d4h/api/models/event"
    autoload :EventResource, "d4h/api/resources/event_resource"

    autoload :Incident, "d4h/api/models/incident"
    autoload :IncidentResource, "d4h/api/resources/incident_resource"

    autoload :Member, "d4h/api/models/member"
    autoload :MemberResource, "d4h/api/resources/member_resource"

    autoload :Team, "d4h/api/models/team"
    autoload :TeamResource, "d4h/api/resources/team_resource"
  end
end
