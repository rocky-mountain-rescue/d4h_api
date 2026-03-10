# frozen_string_literal: true

require "faraday"
require "faraday/middleware"
require "faraday/retry"

module D4H
  module API
    # Public: HTTP client for the D4H Developer API v3.
    #
    # Wraps a Faraday connection with Bearer token authentication and
    # provides accessor methods for every supported API resource.
    #
    # The client builds URL paths as `v3/{context}/{context_id}/{resource}`,
    # where context is typically "team" but can be "organisation" for
    # organisation-scoped endpoints.
    #
    # Examples
    #
    #   # Discover your identity (no context needed)
    #   client = D4H::API::Client.new(api_key: ENV.fetch("D4H_TOKEN"))
    #   me = client.whoami.show
    #
    #   # Team context (default)
    #   client = D4H::API::Client.new(
    #     api_key:    ENV.fetch("D4H_TOKEN"),
    #     context_id: 42,
    #   )
    #   client.member.list
    #   client.event.show(id: 1)
    #
    #   # Organisation context
    #   client = D4H::API::Client.new(
    #     api_key:    ENV.fetch("D4H_TOKEN"),
    #     context:    "organisation",
    #     context_id: 99,
    #   )
    class Client
      # Internal: Default base URL for the D4H API. Override via D4H_BASE_URL
      # env var or the base_url: constructor parameter.
      DEFAULT_BASE_URL = "https://api.team-manager.us.d4h.com"

      # Public: Returns the base URL, API token, Faraday adapter, context type,
      # context ID, max retries, and retry interval.
      attr_reader :base_url, :api_key, :adapter, :context, :context_id, :max_retries, :retry_interval

      # Public: Initialize a new D4H API client.
      #
      # api_key:        - A String Bearer token for API authentication.
      # context:        - The context scope, either "team" (default) or "organisation".
      # context_id:     - The Integer ID of the team or organisation (optional;
      #                   required for all resources except whoami).
      # base_url:       - The base URL for the D4H API. Defaults to D4H_BASE_URL env
      #                   var, or "https://api.team-manager.us.d4h.com" if unset.
      #                   Change this for EU or other regional endpoints.
      # adapter:        - The Faraday adapter to use (default: Faraday.default_adapter).
      #                   Pass `[:test, stubs]` for testing with Faraday::Adapter::Test.
      # max_retries:    - Integer number of retries for transient errors (default: 3).
      #                   Set to 0 to disable retries.
      # retry_interval: - Float base interval in seconds between retries (default: 1).
      #                   Set to 0 in tests to avoid sleeping.
      def initialize(api_key:, context: "team", context_id: nil,
        base_url: ENV.fetch("D4H_BASE_URL", DEFAULT_BASE_URL),
        adapter: Faraday.default_adapter,
        max_retries: MAX_RETRIES, retry_interval: RETRY_INTERVAL)
        @api_key = api_key
        @base_url = base_url
        @context = context
        @context_id = context_id
        @adapter = adapter
        @max_retries = max_retries
        @retry_interval = retry_interval
      end

      # Public: Returns the versioned, context-scoped path prefix.
      #
      # Examples
      #
      #   client.base_path  # => "v3/team/42"
      #
      # Raises ArgumentError if context_id is nil.
      def base_path
        raise ArgumentError, "context_id is required for this resource" if context_id.nil?

        "v3/#{context}/#{context_id}"
      end

      # Internal: Maximum number of retries for transient errors (429, 5xx).
      MAX_RETRIES = 3

      # Internal: Base interval in seconds for exponential backoff.
      RETRY_INTERVAL = 1

      # Internal: Maximum backoff interval in seconds.
      MAX_RETRY_INTERVAL = 30

      # Internal: Backoff factor — each retry doubles the wait time.
      RETRY_BACKOFF_FACTOR = 2

      # Internal: HTTP status codes that are transient and safe to retry.
      RETRIABLE_STATUSES = [429, 500, 502, 503, 504].freeze

      # Internal: HTTP methods to retry. All methods are retriable for
      # transient server errors since the request may not have been processed.
      RETRIABLE_METHODS = %i[delete get head options patch post put].freeze

      # Public: Returns the memoized Faraday connection.
      #
      # Configured with URL-encoded request encoding, JSON response parsing,
      # exponential backoff retry on transient errors, and the chosen adapter.
      #
      # The retry middleware retries on 429 and 5xx status codes up to
      # max_retries times with exponential backoff (1s, 2s, 4s) capped at
      # 30s. It also respects the D4H API's ratelimit headers for wait times.
      # Set max_retries: 0 to disable retries.
      def connection
        @connection ||= Faraday.new do |f|
          f.url_prefix = base_url
          f.request(:url_encoded)
          if max_retries > 0
            f.request(:retry,
              max: max_retries,
              interval: retry_interval,
              max_interval: MAX_RETRY_INTERVAL,
              backoff_factor: RETRY_BACKOFF_FACTOR,
              retry_statuses: RETRIABLE_STATUSES,
              methods: RETRIABLE_METHODS,
              retry_block: ->(env:, options:, retry_count:, exception:, will_retry_in:) {
                Kernel.warn("[D4H] Retry #{retry_count + 1}/#{options.max} for #{env[:method].upcase} " \
                  "#{env[:url]} (#{exception.class}) in #{will_retry_in}s")
              })
          end
          f.response(:json, content_type: "application/json")
          f.adapter(*Array(adapter))
        end
      end

      # Public: Returns a short string representation that hides the API key.
      def inspect
        "#<D4H::Client>"
      end

      # -- Resource accessors --
      #
      # Each method returns a new Resource instance bound to this client.
      # Resources are organized by domain below.

      # Animals
      def animal = AnimalResource.new(self)
      def animal_group = AnimalGroupResource.new(self)
      def animal_group_membership = AnimalGroupMembershipResource.new(self)
      def animal_qualification = AnimalQualificationResource.new(self)

      # Attendance
      def attendance = AttendanceResource.new(self)

      # Custom Fields
      def custom_field = CustomFieldResource.new(self)
      def custom_field_for_entity = CustomFieldForEntityResource.new(self)

      # Documents
      def document = DocumentResource.new(self)

      # Equipment
      def equipment = EquipmentResource.new(self)
      def equipment_brand = EquipmentBrandResource.new(self)
      def equipment_category = EquipmentCategoryResource.new(self)
      def equipment_fund = EquipmentFundResource.new(self)
      def equipment_inspection = EquipmentInspectionResource.new(self)
      def equipment_inspection_result = EquipmentInspectionResultResource.new(self)
      def equipment_inspection_step = EquipmentInspectionStepResource.new(self)
      def equipment_inspection_step_result = EquipmentInspectionStepResultResource.new(self)
      def equipment_kind = EquipmentKindResource.new(self)
      def equipment_location = EquipmentLocationResource.new(self)
      def equipment_model = EquipmentModelResource.new(self)
      def equipment_retired_reason = EquipmentRetiredReasonResource.new(self)
      def equipment_supplier = EquipmentSupplierResource.new(self)
      def equipment_supplier_ref = EquipmentSupplierRefResource.new(self)
      def equipment_usage = EquipmentUsageResource.new(self)

      # Events & Incidents
      def event = EventResource.new(self)
      def exercise = ExerciseResource.new(self)
      def incident = IncidentResource.new(self)
      def incident_involved_injury = IncidentInvolvedInjuryResource.new(self)
      def incident_involved_metadata = IncidentInvolvedMetadataResource.new(self)
      def incident_involved_person = IncidentInvolvedPersonResource.new(self)

      # Handlers
      def handler_group = HandlerGroupResource.new(self)
      def handler_group_membership = HandlerGroupMembershipResource.new(self)
      def handler_qualification = HandlerQualificationResource.new(self)

      # Health & Safety
      def health_safety_category = HealthSafetyCategoryResource.new(self)
      def health_safety_report = HealthSafetyReportResource.new(self)
      def health_safety_severity = HealthSafetySeverityResource.new(self)

      # Members
      def member = MemberResource.new(self)
      def member_custom_status = MemberCustomStatusResource.new(self)
      def member_group = MemberGroupResource.new(self)
      def member_group_membership = MemberGroupMembershipResource.new(self)
      def member_qualification = MemberQualificationResource.new(self)
      def member_qualification_award = MemberQualificationAwardResource.new(self)
      def member_retired_reason = MemberRetiredReasonResource.new(self)

      # Operations & Organization
      def customer_identifier = CustomerIdentifierResource.new(self)
      def d4h_module = D4hModuleResource.new(self)
      def d4h_task = D4hTaskResource.new(self)
      def duty = DutyResource.new(self)
      def location_bookmark = LocationBookmarkResource.new(self)
      def organisation = OrganisationResource.new(self)
      def repair = RepairResource.new(self)
      def resource_bundle = ResourceBundleResource.new(self)
      def role = RoleResource.new(self)
      def search = SearchResultResource.new(self)
      def tag = TagResource.new(self)
      def team = TeamResource.new(self)
      def whiteboard = WhiteboardResource.new(self)
      def whoami = WhoamiResource.new(self)
    end
  end
end
