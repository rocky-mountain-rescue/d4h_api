# D4H API

A Ruby gem wrapping the [D4H Developer API v3](https://api.d4h.com/v3/documentation) with a thin, idiomatic interface. Every API resource is mapped to a Ruby object with dot-notation attribute access, paginated collections, and full CRUD where the API allows it.

## Requirements

- Ruby >= 4.0
- A D4H API token ([generate one in D4H](https://support.d4h.com/en/articles/2334703-api-access))

## Installation

Add to your Gemfile:

```ruby
gem "d4h_api", github: "rockymountainrescue/d4h_api"
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install d4h_api
```

## Quick Start

```ruby
require "d4h"

# Discover your identity (no context_id needed)
client = D4H::API::Client.new(api_key: ENV.fetch("D4H_TOKEN"))
me = client.whoami.show
puts "#{me.name} (#{me.email})"

# Use context_id for all other resources
client = D4H::API::Client.new(
  api_key:    ENV.fetch("D4H_TOKEN"),
  context_id: ENV.fetch("D4H_TEAM_ID").to_i,
)

# List all operational members
members = client.member.list(status: "OPERATIONAL")
members.each { |m| puts m.name }

# Show team info
team = client.team.show(id: 42)
puts "#{team.title} — #{team.country}"
```

## Configuration

### Client Initialization

The client requires an `api_key`. The `context_id` (your D4H team or organisation ID) is optional — it is required for all resources except `whoami`, which can be used to discover your context. The `context` defaults to `"team"` but can be set to `"organisation"` for organisation-scoped API calls.

```ruby
# Minimal client — only whoami is available (no context_id)
client = D4H::API::Client.new(api_key: ENV.fetch("D4H_TOKEN"))
me = client.whoami.show

# Team context (default)
client = D4H::API::Client.new(
  api_key:    ENV.fetch("D4H_TOKEN"),
  context_id: ENV.fetch("D4H_TEAM_ID").to_i,
)

# Organisation context
client = D4H::API::Client.new(
  api_key:    ENV.fetch("D4H_TOKEN"),
  context:    "organisation",
  context_id: ENV.fetch("D4H_ORG_ID").to_i,
)

# EU or other regional endpoint
client = D4H::API::Client.new(
  api_key:    ENV.fetch("D4H_TOKEN"),
  context_id: ENV.fetch("D4H_TEAM_ID").to_i,
  base_url:   "https://api.team-manager.eu.d4h.com",
)
```

### Environment Variables

The client reads the following environment variables as defaults. All can be overridden via constructor arguments.

| Variable       | Default                               | Constructor param | Description                                                               |
|----------------|---------------------------------------|-------------------|---------------------------------------------------------------------------|
| `D4H_TOKEN`    | *(required)*                          | `api_key:`        | Your D4H API Bearer token. Generate one in your [D4H account settings](https://support.d4h.com/en/articles/2334703-api-access). |
| `D4H_TEAM_ID`  | *(optional)*                          | `context_id:`     | Your D4H team (or organisation) numeric ID. Required for all resources except `whoami`. Find it in your D4H URL or via the `whoami` endpoint. |
| `D4H_BASE_URL` | `https://api.team-manager.us.d4h.com` | `base_url:`       | Base URL for the D4H API. Change for EU (`https://api.team-manager.eu.d4h.com`) or other regional endpoints. |

A typical `.env` file:

```bash
D4H_TOKEN="your-api-token-here"
D4H_TEAM_ID="42"
# D4H_BASE_URL="https://api.team-manager.eu.d4h.com"  # uncomment for EU
```

## Architecture

The gem is built around four core classes that work together in a simple pipeline:

```
Client  ──▶  Resource  ──▶  Model / Collection
  │              │                 │
  │  Faraday     │  HTTP verbs     │  Dot-notation
  │  connection  │  + URL routing  │  attribute access
  │  + auth      │  + pagination   │  + Enumerable
  │  + retry     │  + error check  │
```

### How a request flows

When you call `client.member.list(status: "OPERATIONAL")`, here's what happens:

```
1. client.member           →  creates a MemberResource bound to the client
2. .list(status: "...")    →  MemberResource calls get_request on the resource URL
3. Resource builds the URL →  "v3/team/42/members" (from base_path + SUB_URL)
4. Resource adds auth      →  Authorization: Bearer <token>
5. Faraday sends GET       →  GET https://api.team-manager.us.d4h.com/v3/team/42/members?status=OPERATIONAL
6. Retry middleware         →  429/5xx? → exponential backoff and retry (up to 3 times)
7. Resource checks status  →  2xx → continue, otherwise raise D4H::API::Error
8. Response body parsed    →  Collection wraps the JSON envelope, each result becomes a Member model
9. You get back a          →  Collection (Enumerable) of Member objects with dot-notation access
```

### The four core classes

**`D4H::API::Client`** is the entry point. It holds your API credentials, builds the Faraday HTTP connection, and exposes 56 resource accessor methods. Each accessor returns a fresh Resource instance bound to the client:

```ruby
client = D4H::API::Client.new(api_key: "token", context_id: 42)

client.member        # => MemberResource.new(client)
client.equipment     # => EquipmentResource.new(client)
client.event         # => EventResource.new(client)
```

The client builds a **base path** from the context — `v3/team/42` for team context, `v3/organisation/99` for organisation context — which most resources prepend to their endpoint URLs. The `context_id` is optional; when omitted, only context-free resources like `whoami` (which uses `v3/whoami`) are available. Calling a context-scoped resource without a `context_id` raises `ArgumentError`.

**`D4H::API::Resource`** is the base class for all 56 resource endpoints. It provides five HTTP verb methods (`get_request`, `post_request`, `put_request`, `patch_request`, `delete_request`), each of which injects the Bearer token header and checks the response status. Every subclass defines a `SUB_URL` constant and implements only the CRUD methods the D4H API supports for that resource:

```ruby
class TagResource < Resource
  SUB_URL = "tags"              # → URL becomes "v3/team/42/tags"

  def list(**params)            # GET    /v3/team/42/tags
  def show(id:)                 # GET    /v3/team/42/tags/{id}
  def create(data)              # POST   /v3/team/42/tags
  def update(id:, **params)     # PATCH  /v3/team/42/tags/{id}
  def destroy(id:)              # DELETE /v3/team/42/tags/{id}
end
```

Resource also provides a private `paginate_all` helper used by `list_all` methods — it fetches pages in a loop until all results are collected, then returns a single Collection.

**`D4H::API::Model`** wraps a JSON response hash in an OpenStruct with recursive conversion, so nested hashes and arrays become dot-accessible objects all the way down:

```ruby
# The API returns:  {"id" => 10, "brand" => {"id" => 3, "title" => "Petzl"}}
# Model gives you:  item.brand.title  # => "Petzl"
```

Each API resource has a corresponding thin Model subclass (e.g. `Member`, `Event`, `Equipment`) that inherits from Model. These exist for type identification — `item.is_a?(D4H::API::Equipment)` — but add no extra behavior. The original JSON hash is preserved in `#to_json`.

**`D4H::API::Collection`** wraps the D4H v3 list envelope (`results`, `page`, `pageSize`, `totalSize`). It converts each result into the appropriate Model subclass and includes `Enumerable`, so you can use `map`, `select`, `first`, `count`, and all other Enumerable methods directly:

```ruby
collection = client.member.list    # Collection of Member models
collection.total_size              # pagination metadata
collection.map(&:name)            # Enumerable — iterate the results
```

### File layout

```
lib/
  d4h.rb                          # Gem entry point — Zeitwerk setup + autoloads
  d4h/api/
    client.rb                     # Client — connection + 56 resource accessors
    resource.rb                   # Resource — HTTP verbs, auth, pagination
    model.rb                      # Model — recursive OpenStruct wrapper
    collection.rb                 # Collection — Enumerable list envelope
    error.rb                      # Error + RetriableError — raised on failures
    models/                       # 56 thin Model subclasses (member.rb, event.rb, ...)
    resources/                    # 56 Resource subclasses (member_resource.rb, ...)
```

### Method signatures

Resources follow consistent method signatures depending on the operation:

```ruby
# List — returns a Collection, accepts filter params
client.member.list(status: "OPERATIONAL", size: 10)

# List all — auto-paginates, same params as list
client.member.list_all(status: "OPERATIONAL")

# Show — returns a single Model, requires id:
client.event.show(id: 1)

# Create — returns the created Model, accepts a Hash body
client.event.create({"title" => "Training", "startsAt" => "2026-03-09T08:00:00Z"})

# Update — returns the updated Model, requires id: plus keyword params
client.event.update(id: 1, title: "Updated Training")

# Destroy — returns the raw response, requires id:
client.tag.destroy(id: 5)
```

Two special cases: `whoami.show` takes no arguments and does not require a `context_id` (it hits `v3/whoami` directly to return the authenticated user), and `document.update` uses HTTP PUT instead of PATCH per the D4H API contract.

## Usage

### Response Objects

Every API call returns a **Model** — an OpenStruct with recursive dot-notation access to all attributes, including nested hashes and arrays.

```ruby
event = client.event.show(id: 1)

event.id            # => 1
event.reference     # => "EVT-001"
event.description   # => "Monthly training drill"
```

Nested data is automatically accessible:

```ruby
item = client.equipment.show(id: 10)

item.ref             # => "E010"
item.brand.title     # => "Petzl"
item.owner.id        # => 42
```

The original JSON hash is always available via `#to_json`:

```ruby
event.to_json
# => {"id" => 1, "reference" => "EVT-001", "description" => "Monthly training drill"}
```

### Collections

List endpoints return a **Collection** — an Enumerable wrapper around paginated results.

```ruby
members = client.member.list

members.results       # => Array of Member models
members.total_size    # => 90
members.page          # => 0
members.page_size     # => 25
```

Collections include `Enumerable`, so you can use `each`, `map`, `select`, `first`, and more:

```ruby
# Get all member names
names = client.member.list.map(&:name)

# Find operational members
ops = client.member.list(status: "OPERATIONAL").select { |m| m.status == "OPERATIONAL" }

# Grab the first result
leader = client.role.list.first
puts leader.title  # => "Team Leader"
```

### Pagination

Single-page results use `list`. To automatically fetch **all pages**, use `list_all`:

```ruby
# Fetch first page (default 25 results)
page = client.member.list

# Fetch ALL members across all pages (250 per page by default)
everyone = client.member.list_all
everyone.total_size  # => 90
everyone.count       # => 90

# Custom page size
everyone = client.member.list_all(size: 50)

# Combine with filters
operational = client.member.list_all(status: "OPERATIONAL")
```

### Error Handling

Non-2xx responses raise `D4H::API::Error` with the API's error message:

```ruby
begin
  client.equipment.show(id: 999_999)
rescue D4H::API::Error => e
  puts e.message  # => "Not Found: Equipment not found"
end
```

Transient errors (429 rate limit, 500, 502, 503, 504) raise `D4H::API::RetriableError`, a subclass of `Error`. You can rescue either:

```ruby
# Catch only transient failures (after retries are exhausted)
rescue D4H::API::RetriableError => e
  puts "Server is overloaded: #{e.message}"

# Catch all API errors (including transient)
rescue D4H::API::Error => e
  puts "Something went wrong: #{e.message}"
```

### Retry & Rate Limiting

The client automatically retries transient errors with exponential backoff. This handles the D4H API's [sliding-window rate limiting](https://api.d4h.com/v3/documentation) — when request frequency exceeds the limit, the API returns 429 and the client backs off and retries.

**Default behavior:**
- Retries up to **3 times** on 429, 500, 502, 503, and 504 responses
- Exponential backoff: **1s, 2s, 4s** (doubles each retry), capped at 30s
- Respects the D4H API's `ratelimit` response headers for wait times
- Retries **all HTTP methods** (GET, POST, PATCH, PUT, DELETE)
- Logs each retry to stderr: `[D4H] Retry 1/3 for GET .../members ...`

**Customize retry behavior:**

```ruby
# More retries for batch scripts
client = D4H::API::Client.new(
  api_key:    "your-token",
  context_id: 42,
  max_retries: 5,
)

# Disable retries entirely
client = D4H::API::Client.new(
  api_key:    "your-token",
  context_id: 42,
  max_retries: 0,
)
```

If all retries are exhausted, the `RetriableError` propagates to your code so you can handle it as needed.

## API Resources

### Team & Identity

```ruby
# Show your own profile (no context_id needed)
client = D4H::API::Client.new(api_key: ENV.fetch("D4H_TOKEN"))
me = client.whoami.show
me.name   # => "John Doe"
me.email  # => "john@example.com"

# Show your team's info (requires context_id)
team = client.team.show(id: 42)
team.title       # => "Rocky Mountain Rescue"
team.timezone    # => "America/Denver"
team.memberCounts.total        # => 90
team.memberCounts.operational  # => 85

# Show an organisation
org = client.organisation.show(id: 5)
org.title  # => "Colorado SAR"
```

### Members

Members can be listed, filtered, and updated — but not created or destroyed through the API.

```ruby
# List members
members = client.member.list
members.each { |m| puts "#{m.name}: #{m.status}" }

# Filter by status
active = client.member.list(status: "OPERATIONAL")

# Fetch all members across pages
everyone = client.member.list_all
puts "Total members: #{everyone.total_size}"

# Update a member
updated = client.member.update(id: 1, name: "Alice Smith")
puts updated.name  # => "Alice Smith"
```

### Events

Events support list, show, create, and update — but not destroy.

```ruby
# List events
events = client.event.list
events.each { |e| puts "#{e.reference}: #{e.description}" }

# Show a specific event
event = client.event.show(id: 1)
puts event.description  # => "Monthly drill"

# Create an event
new_event = client.event.create({
  "reference"  => "EVT-010",
  "startsAt"   => "2026-03-09T08:00:00Z",
  "endsAt"     => "2026-03-09T17:00:00Z",
  "title"      => "Spring Training",
})
puts new_event.id  # => 10

# Update an event
client.event.update(id: 1, description: "Updated drill description")
```

### Incidents

Incidents support list, show, create, and update — but not destroy.

```ruby
# List incidents
incidents = client.incident.list_all
incidents.each { |i| puts "#{i.reference}: #{i.description}" }

# Show a specific incident
incident = client.incident.show(id: 7)
puts incident.description  # => "Missing hiker"

# Create an incident
new_incident = client.incident.create({
  "reference"   => "INC-008",
  "description" => "Lost hikers near Flatirons",
})
puts new_incident.id  # => 8

# Update an incident
client.incident.update(id: 7, description: "Missing hiker — found safe")
```

### Exercises

Exercises support full CRUD.

```ruby
# List exercises
client.exercise.list.each { |ex| puts ex.reference }

# Create an exercise
ex = client.exercise.create({"reference" => "EX-005", "title" => "Night Navigation"})

# Update an exercise
client.exercise.update(id: ex.id, title: "Night Navigation — Advanced")

# Destroy an exercise
client.exercise.destroy(id: ex.id)
```

### Attendance

Attendance records can be listed, shown, and created — but not updated or destroyed.

```ruby
# List attendance
records = client.attendance.list
records.each { |a| puts "#{a.status} — Member #{a.member.id}" }

# Show a specific attendance record
att = client.attendance.show(id: 100)
puts att.status      # => "ATTENDING"
puts att.member.id   # => 1

# Record attendance
new_att = client.attendance.create({
  "memberId"   => 1,
  "activityId" => 5,
  "status"     => "ATTENDING",
})
```

### Equipment

Equipment supports full CRUD with nested data.

```ruby
# List equipment with filters
critical = client.equipment.list(is_critical: true, size: 10)

# Show equipment details
item = client.equipment.show(id: 10)
puts item.ref            # => "E010"
puts item.brand.title    # => "Petzl"
puts item.owner.id       # => 42

# Create equipment
new_item = client.equipment.create({
  "ref"        => "E100",
  "categoryId" => 1,
  "kindId"     => 2,
})
puts new_item.ref  # => "E100"

# Update equipment
client.equipment.update(id: 10, ref: "E010-A")

# Destroy equipment
client.equipment.destroy(id: 10)
```

### Documents

Documents support full CRUD. Note that **update uses PUT** (not PATCH) per the D4H API.

```ruby
# List documents
docs = client.document.list
docs.each { |d| puts d.title }

# Show a document
doc = client.document.show(id: 1)
puts doc.title  # => "SOP Manual"

# Create a document
new_doc = client.document.create({"title" => "New Procedure"})

# Update a document (uses PUT)
client.document.update(id: 1, title: "Updated SOP Manual")

# Destroy a document
client.document.destroy(id: 1)
```

### Tags

Tags support full CRUD.

```ruby
# List tags
client.tag.list.each { |t| puts t.title }

# Show a tag
tag = client.tag.show(id: 5)
puts tag.title  # => "Avalanche"

# Create a tag
new_tag = client.tag.create({"title" => "High Angle"})
puts new_tag.id  # => 10

# Update a tag
client.tag.update(id: 5, title: "Avalanche Response")

# Destroy a tag
client.tag.destroy(id: 5)
```

### Custom Fields

```ruby
# List custom fields
fields = client.custom_field.list
fields.each { |f| puts "#{f.title} (#{f.type})" }

# Show a custom field
cf = client.custom_field.show(id: 3)
puts cf.title  # => "Badge Number"
puts cf.type   # => "TEXT"

# Create / update / destroy
client.custom_field.create({"title" => "Radio Call Sign", "type" => "TEXT"})
client.custom_field.update(id: 3, title: "Employee Badge")
client.custom_field.destroy(id: 3)

# List custom field options for entities
options = client.custom_field_for_entity.list
opt = client.custom_field_for_entity.show(id: 1)
puts opt.label  # => "Option A"
```

### Member Groups & Qualifications

```ruby
# Member groups (full CRUD)
groups = client.member_group.list
client.member_group.create({"title" => "Bravo Team"})
client.member_group.destroy(id: 1)

# Member group memberships (read-only)
memberships = client.member_group_membership.list

# Member qualifications (read-only)
quals = client.member_qualification.list
quals.each { |q| puts q.title }

# Award a qualification to a member (create only, no show/update/destroy)
client.member_qualification_award.create({
  "memberId"        => 10,
  "qualificationId" => 5,
})
```

### Roles & Duties

```ruby
# List and show roles (read-only)
roles = client.role.list
role = client.role.show(id: 1)
puts role.title  # => "Team Leader"

# List and show duties (read-only)
duties = client.duty.list
duty = client.duty.show(id: 1)
```

### Health & Safety

```ruby
# Reports (read-only)
reports = client.health_safety_report.list
puts reports.first.title  # => "Near miss"

# Categories (full CRUD)
categories = client.health_safety_category.list
client.health_safety_category.create({"title" => "Equipment Failure"})

# Severities (full CRUD)
client.health_safety_severity.list
```

### Animals & Handlers

```ruby
# Animals (read-only)
animals = client.animal.list
animal = client.animal.show(id: 1)
puts "#{animal.name} — #{animal.breed}"

# Animal groups (full CRUD)
client.animal_group.create({"title" => "Tracking Dogs"})
client.animal_group.destroy(id: 2)

# Handler groups (full CRUD)
client.handler_group.list

# Handler qualifications (read-only)
client.handler_qualification.list
```

### Whiteboard

```ruby
# Full CRUD
notes = client.whiteboard.list
note = client.whiteboard.create({"title" => "Weather advisory"})
client.whiteboard.update(id: note.id, title: "Storm warning")
client.whiteboard.destroy(id: note.id)
```

### Repairs

```ruby
# Full CRUD
repairs = client.repair.list
repair = client.repair.create({"description" => "Replace worn rope"})
client.repair.update(id: repair.id, description: "Replace worn rope — completed")
client.repair.destroy(id: repair.id)
```

### Search

```ruby
# Search across resources (read-only)
results = client.search.list(query: "rope")
results.each { |r| puts "#{r.resourceType}: #{r.title}" }
```

## Complete Resource Reference

Every resource is accessible as a method on the client. The table below shows which operations each resource supports.

| Client Method | API Endpoint | list | show | create | update | destroy |
|---|---|:---:|:---:|:---:|:---:|:---:|
| `animal` | animals | x | x | | | |
| `animal_group` | animal-groups | x | x | x | x | x |
| `animal_group_membership` | animal-group-memberships | x | x | | | |
| `animal_qualification` | animal-qualifications | x | x | | | |
| `attendance` | attendance | x | x | x | | |
| `custom_field` | custom-fields | x | x | x | x | x |
| `custom_field_for_entity` | custom-field-options | x | x | | | |
| `customer_identifier` | customer-identifiers | x | | | | |
| `d4h_module` | modules | x | | | | |
| `d4h_task` | tasks | x | | | | |
| `document` | documents | x | x | x | x* | x |
| `duty` | duties | x | x | | | |
| `equipment` | equipment | x | x | x | x | x |
| `equipment_brand` | equipment-brands | x | x | x | x | x |
| `equipment_category` | equipment-categories | x | x | x | x | x |
| `equipment_fund` | equipment-funds | x | x | x | x | x |
| `equipment_inspection` | equipment-inspections | x | x | | | |
| `equipment_inspection_result` | equipment-inspection-results | x | x | | x | x |
| `equipment_inspection_step` | equipment-inspection-steps | x | x | x | x | x |
| `equipment_inspection_step_result` | equipment-inspection-step-results | x | x | x | x | x |
| `equipment_kind` | equipment-kinds | x | x | x | x | x |
| `equipment_location` | equipment-locations | x | x | | | |
| `equipment_model` | equipment-models | x | x | x | x | x |
| `equipment_retired_reason` | equipment-retired-reasons | x | x | x | x | x |
| `equipment_supplier` | equipment-suppliers | x | x | x | x | x |
| `equipment_supplier_ref` | equipment-supplier-refs | x | x | x | x | x |
| `equipment_usage` | equipment-usages | x | x | x | x | x |
| `event` | events | x | x | x | x | |
| `exercise` | exercises | x | x | x | x | x |
| `handler_group` | handler-groups | x | x | x | x | x |
| `handler_group_membership` | handler-group-memberships | x | x | | | |
| `handler_qualification` | handler-qualifications | x | x | | | |
| `health_safety_category` | health-safety-categories | x | x | x | x | x |
| `health_safety_report` | health-safety-reports | x | x | | | |
| `health_safety_severity` | health-safety-severities | x | x | x | x | x |
| `incident` | incidents | x | x | x | x | |
| `incident_involved_injury` | incident-involved-injuries | x | x | | | |
| `incident_involved_metadata` | incident-involved-metadata | x | | | | |
| `incident_involved_person` | incident-involved-persons | x | x | | | |
| `location_bookmark` | location-bookmarks | x | x | | | |
| `member` | members | x | | | x | |
| `member_custom_status` | member-custom-statuses | x | | | | |
| `member_group` | member-groups | x | x | x | x | x |
| `member_group_membership` | member-group-memberships | x | x | | | |
| `member_qualification` | member-qualifications | x | x | | | |
| `member_qualification_award` | member-qualification-awards | x | | x | | |
| `member_retired_reason` | member-retired-reasons | x | | | | |
| `organisation` | organisations | | x | | | |
| `repair` | repairs | x | x | x | x | x |
| `resource_bundle` | resource-bundles | x | x | | | |
| `role` | roles | x | x | | | |
| `search` | search | x | | | | |
| `tag` | tags | x | x | x | x | x |
| `team` | teams | | x | | | |
| `whiteboard` | whiteboard | x | x | x | x | x |
| `whoami` | whoami | | x** | | | |

\* Document update uses PUT instead of PATCH.
\*\* Whoami `show` takes no arguments and does not require `context_id` — it hits `v3/whoami` directly to return the current authenticated user.

All resources with `list` also support `list_all` for automatic pagination.

## Development

```bash
git clone https://github.com/rockymountainrescue/d4h_api.git
cd d4h_api
bin/setup
```

Run the full test suite:

```bash
bin/rake test
```

Run code quality checks (Reek + RuboCop):

```bash
bin/rake code_quality
```

Run everything (quality + tests):

```bash
bin/rake
```

Open an interactive console:

```bash
bin/console
```

## [License](LICENSE.md)

Hippocratic License 2.1

## [Versions](VERSIONS.md)

## Credits

Built by [Rocky Mountain Rescue Group](https://rockymountainrescue.org) and [Pawel Osiczko](https://github.com/posiczko).
