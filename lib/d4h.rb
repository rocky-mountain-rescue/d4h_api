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
    # Core
    autoload :Client, "d4h/api/client"
    autoload :Collection, "d4h/api/collection"
    autoload :Error, "d4h/api/error"
    autoload :RetriableError, "d4h/api/error"
    autoload :Model, "d4h/api/model"
    autoload :Resource, "d4h/api/resource"

    # Animals
    autoload :Animal, "d4h/api/models/animal"
    autoload :AnimalResource, "d4h/api/resources/animal_resource"
    autoload :AnimalGroup, "d4h/api/models/animal_group"
    autoload :AnimalGroupResource, "d4h/api/resources/animal_group_resource"
    autoload :AnimalGroupMembership, "d4h/api/models/animal_group_membership"
    autoload :AnimalGroupMembershipResource, "d4h/api/resources/animal_group_membership_resource"
    autoload :AnimalQualification, "d4h/api/models/animal_qualification"
    autoload :AnimalQualificationResource, "d4h/api/resources/animal_qualification_resource"

    # Attendance
    autoload :Attendance, "d4h/api/models/attendance"
    autoload :AttendanceResource, "d4h/api/resources/attendance_resource"

    # Custom Fields
    autoload :CustomField, "d4h/api/models/custom_field"
    autoload :CustomFieldResource, "d4h/api/resources/custom_field_resource"
    autoload :CustomFieldForEntity, "d4h/api/models/custom_field_for_entity"
    autoload :CustomFieldForEntityResource, "d4h/api/resources/custom_field_for_entity_resource"

    # Documents
    autoload :Document, "d4h/api/models/document"
    autoload :DocumentResource, "d4h/api/resources/document_resource"

    # Equipment
    autoload :Equipment, "d4h/api/models/equipment"
    autoload :EquipmentResource, "d4h/api/resources/equipment_resource"
    autoload :EquipmentBrand, "d4h/api/models/equipment_brand"
    autoload :EquipmentBrandResource, "d4h/api/resources/equipment_brand_resource"
    autoload :EquipmentCategory, "d4h/api/models/equipment_category"
    autoload :EquipmentCategoryResource, "d4h/api/resources/equipment_category_resource"
    autoload :EquipmentFund, "d4h/api/models/equipment_fund"
    autoload :EquipmentFundResource, "d4h/api/resources/equipment_fund_resource"
    autoload :EquipmentInspection, "d4h/api/models/equipment_inspection"
    autoload :EquipmentInspectionResource, "d4h/api/resources/equipment_inspection_resource"
    autoload :EquipmentInspectionResult, "d4h/api/models/equipment_inspection_result"
    autoload :EquipmentInspectionResultResource, "d4h/api/resources/equipment_inspection_result_resource"
    autoload :EquipmentInspectionStep, "d4h/api/models/equipment_inspection_step"
    autoload :EquipmentInspectionStepResource, "d4h/api/resources/equipment_inspection_step_resource"
    autoload :EquipmentInspectionStepResult, "d4h/api/models/equipment_inspection_step_result"
    autoload :EquipmentInspectionStepResultResource, "d4h/api/resources/equipment_inspection_step_result_resource"
    autoload :EquipmentKind, "d4h/api/models/equipment_kind"
    autoload :EquipmentKindResource, "d4h/api/resources/equipment_kind_resource"
    autoload :EquipmentLocation, "d4h/api/models/equipment_location"
    autoload :EquipmentLocationResource, "d4h/api/resources/equipment_location_resource"
    autoload :EquipmentModel, "d4h/api/models/equipment_model"
    autoload :EquipmentModelResource, "d4h/api/resources/equipment_model_resource"
    autoload :EquipmentRetiredReason, "d4h/api/models/equipment_retired_reason"
    autoload :EquipmentRetiredReasonResource, "d4h/api/resources/equipment_retired_reason_resource"
    autoload :EquipmentSupplier, "d4h/api/models/equipment_supplier"
    autoload :EquipmentSupplierResource, "d4h/api/resources/equipment_supplier_resource"
    autoload :EquipmentSupplierRef, "d4h/api/models/equipment_supplier_ref"
    autoload :EquipmentSupplierRefResource, "d4h/api/resources/equipment_supplier_ref_resource"
    autoload :EquipmentUsage, "d4h/api/models/equipment_usage"
    autoload :EquipmentUsageResource, "d4h/api/resources/equipment_usage_resource"

    # Events & Exercises
    autoload :Event, "d4h/api/models/event"
    autoload :EventResource, "d4h/api/resources/event_resource"
    autoload :Exercise, "d4h/api/models/exercise"
    autoload :ExerciseResource, "d4h/api/resources/exercise_resource"

    # Handlers
    autoload :HandlerGroup, "d4h/api/models/handler_group"
    autoload :HandlerGroupResource, "d4h/api/resources/handler_group_resource"
    autoload :HandlerGroupMembership, "d4h/api/models/handler_group_membership"
    autoload :HandlerGroupMembershipResource, "d4h/api/resources/handler_group_membership_resource"
    autoload :HandlerQualification, "d4h/api/models/handler_qualification"
    autoload :HandlerQualificationResource, "d4h/api/resources/handler_qualification_resource"

    # Health & Safety
    autoload :HealthSafetyCategory, "d4h/api/models/health_safety_category"
    autoload :HealthSafetyCategoryResource, "d4h/api/resources/health_safety_category_resource"
    autoload :HealthSafetyReport, "d4h/api/models/health_safety_report"
    autoload :HealthSafetyReportResource, "d4h/api/resources/health_safety_report_resource"
    autoload :HealthSafetySeverity, "d4h/api/models/health_safety_severity"
    autoload :HealthSafetySeverityResource, "d4h/api/resources/health_safety_severity_resource"

    # Incidents
    autoload :Incident, "d4h/api/models/incident"
    autoload :IncidentResource, "d4h/api/resources/incident_resource"
    autoload :IncidentInvolvedInjury, "d4h/api/models/incident_involved_injury"
    autoload :IncidentInvolvedInjuryResource, "d4h/api/resources/incident_involved_injury_resource"
    autoload :IncidentInvolvedMetadata, "d4h/api/models/incident_involved_metadata"
    autoload :IncidentInvolvedMetadataResource, "d4h/api/resources/incident_involved_metadata_resource"
    autoload :IncidentInvolvedPerson, "d4h/api/models/incident_involved_person"
    autoload :IncidentInvolvedPersonResource, "d4h/api/resources/incident_involved_person_resource"

    # Members
    autoload :Member, "d4h/api/models/member"
    autoload :MemberResource, "d4h/api/resources/member_resource"
    autoload :MemberCustomStatus, "d4h/api/models/member_custom_status"
    autoload :MemberCustomStatusResource, "d4h/api/resources/member_custom_status_resource"
    autoload :MemberGroup, "d4h/api/models/member_group"
    autoload :MemberGroupResource, "d4h/api/resources/member_group_resource"
    autoload :MemberGroupMembership, "d4h/api/models/member_group_membership"
    autoload :MemberGroupMembershipResource, "d4h/api/resources/member_group_membership_resource"
    autoload :MemberQualification, "d4h/api/models/member_qualification"
    autoload :MemberQualificationResource, "d4h/api/resources/member_qualification_resource"
    autoload :MemberQualificationAward, "d4h/api/models/member_qualification_award"
    autoload :MemberQualificationAwardResource, "d4h/api/resources/member_qualification_award_resource"
    autoload :MemberRetiredReason, "d4h/api/models/member_retired_reason"
    autoload :MemberRetiredReasonResource, "d4h/api/resources/member_retired_reason_resource"

    # Operations & Organization
    autoload :CustomerIdentifier, "d4h/api/models/customer_identifier"
    autoload :CustomerIdentifierResource, "d4h/api/resources/customer_identifier_resource"
    autoload :D4hModule, "d4h/api/models/d4h_module"
    autoload :D4hModuleResource, "d4h/api/resources/d4h_module_resource"
    autoload :D4hTask, "d4h/api/models/d4h_task"
    autoload :D4hTaskResource, "d4h/api/resources/d4h_task_resource"
    autoload :Duty, "d4h/api/models/duty"
    autoload :DutyResource, "d4h/api/resources/duty_resource"
    autoload :LocationBookmark, "d4h/api/models/location_bookmark"
    autoload :LocationBookmarkResource, "d4h/api/resources/location_bookmark_resource"
    autoload :Organisation, "d4h/api/models/organisation"
    autoload :OrganisationResource, "d4h/api/resources/organisation_resource"
    autoload :Repair, "d4h/api/models/repair"
    autoload :RepairResource, "d4h/api/resources/repair_resource"
    autoload :ResourceBundle, "d4h/api/models/resource_bundle"
    autoload :ResourceBundleResource, "d4h/api/resources/resource_bundle_resource"
    autoload :Role, "d4h/api/models/role"
    autoload :RoleResource, "d4h/api/resources/role_resource"
    autoload :SearchResult, "d4h/api/models/search_result"
    autoload :SearchResultResource, "d4h/api/resources/search_result_resource"
    autoload :Tag, "d4h/api/models/tag"
    autoload :TagResource, "d4h/api/resources/tag_resource"
    autoload :Team, "d4h/api/models/team"
    autoload :TeamResource, "d4h/api/resources/team_resource"
    autoload :Whiteboard, "d4h/api/models/whiteboard"
    autoload :WhiteboardResource, "d4h/api/resources/whiteboard_resource"
    autoload :Whoami, "d4h/api/models/whoami"
    autoload :WhoamiResource, "d4h/api/resources/whoami_resource"
  end
end
