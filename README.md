# D4H API Gem

[D4H Developer API](https://api.d4h.org/v2/documentation)
allows developers to access data for D4H via API. This gem wraps
the API providing a thin encapsulation layer.

## Installation

To use D4H in the Rails application or as a gem, add this line to your
application's Gemfile:

```
gem "d4h_api", github: "https://github.com/rocky-mountain-rescue/d4h_api"
```

Afterwards update your Gemfile by executing:

```
$ bundle
```

You can also manually install it yourself via:

```
$ gem install d4h_api
```

## Usage

To access the Active911 API, you'll need to create/instantiate an
`D4H::API::Client` passing in the `api_key`.

```ruby
client = D4H::API::Client.new(api_key: ENV.fetch("D4H_TOKEN"))
```

Upon instantiation, the client gives you access to the following D4H resources:

* attendance
* custom_field_for_entity
* event (list, list_all, create)
* incident
* member
* team (show)

### Environmental Variables

D4H::API::Client can read the following environmental variables:

```bash
D4H_BASE_URL="https://api.d4h.org/v2"
```

In addition, the constructor for the client requires `api_key`
argument, which, as a convention, can be read from the environment.
The `D4H_BASE_URL` contains the base URL for the D4H API. 
`D4H_BASE_URL` defaults to `https://api.d4h.org/v2`. 

### Returned Data Format

The object returned is a recursively constructed OpenStruct data:

* at the first level `statusCode` provides the HTTP status returned from the API
* in addition, at the first level, `data` provides the data structure returned from the API

The unaltered data from the API is available via `#to_json` method, for example:

```ruby
client = D4H::API::Client.new(api_key: ENV.fetch("D4H_TOKEN"))
team = client.team.show()

team.statusCode
# => 200

team.data.id
# => 1

team.data.title
# => "Mountain Rescue Group"

jj team.to_json

{
        "statusCode": 200,
        "data": {
                "id": 1,
                "organisation_id": null,
                "title": "Mountain Rescue Group",
                "lat": 40.0,
                "lng": -105.0,
                "count_members": 90,
                "count_operational": 90,
                "country": "US",
                "timezone": {
                        "location": "America/Denver",
                        "offset": "-06:00"
                },
                "units": {
                        "currency": "USD",
                        "currency_symbol": "$",
                        "distance": {
                                "name": "mile",
                                "symbol": "mi"
                        },
                        "weight": {
                                "name": "imperial",
                                "units": "lbs"
                        }
                },
                "required_oncall": 0,
                "default_duty": 1,
                "calendar_dashboard_activities": 5,
                "subdomain": "mrg",
                "created_at": "2023-01-01T00:00:01.000Z",
                "updated_at": "2023-02-02T00:00:01.000Z"
        },
        "meta": {
        }
}
```

The object returned from the Active911 API is recursively encoded via
OpenStruct. The original json encoding is also available via `#to_json`
method call.

## API Resources

### Team

To obtain information about all the team normally available via the
D4H API URL `https://api.d4h.org/v2/documentation#tag/team`,
issue the following call:

```ruby
client.team.show
```

Resulting data is an OpenStruct and JSON coded object corresponding to the
returned API object describing the agency and agency associated devices.

```json
{
  "statusCode": 200,
  "data": {
    "id": "(Agency id number as int)",
    "organisation_id": null,
    "title": "(Name of the agency)",
    "lat": "(Latitude of the agency headquarters as float)",
    "lng": "(Longitude of the agency headquarters as float)",
    "count_members": "(Agency member count as int)",
    "count_operational": "(Agency operational member count as int)",
    "country": "(Country)",
    "timezone": {
      "location": "(Timezone)",
      "offset": "(Timezone offset)"
    },
    "units": {
      "currency": "(Currency)",
      "currency_symbol": "(Currency symbol)",
      "distance": {
        "name": "(Distance unit name)",
        "symbol": "(Distance unit abbreviation)"
      },
      "weight": {
        "name": "(Weight system (imperial|metric))",
        "units": "(lbs|kg)"
      }
    },
    "required_oncall": "(Required oncall duty personnel)",
    "default_duty": "(Default on duty count)",
    "calendar_dashboard_activities": 5,
    "subdomain": "Subdomain",
    "created_at": "(Creation timestamp)",
    "updated_at": "(Update timestamp)"
  },
  "meta": {
  }
}
```

### Event

To obtain information about all the alerts normally available via the
D4H API URL `https://api.d4h.org/v2/documentation#tag/team`,
issue the following call:

```ruby
client.alerts.index
```

By default, 10 days of last alerts will be returned. Specify either
`alert_days` or `alert_minutes` to show specific date. Specifying
`alert_minutes` will supersede `alert_days`. Maximum of `30` days of alerts
can be shown, e.g.:

```ruby
client.alerts.index(alert_days: 30)
#
client.alerts.index(alert_minutes: 15)
```

Resulting data is an OpenStruct and JSON coded object corresponding to the
returned API object describing the alerts and urls to retrieve them.

The API returns a JSON object that is formatted as follows:

```json
{
  "alerts": [
    {
      "id": "(Active911 Alert id number)",
      "uri": "(API URI to access the alert data)"
    }
  ]
}
```

### Alert

To obtain information about a specific alert normally available via the
D4H API URL `https://access.active911.com/interface/open_api/api/alerts/:id`,
issue the following client method call:

```ruby
client.alerts.show(alert_id: alert_id)
```

You will need to specify the `alert_id`.

Resulting data is an OpenStruct and JSON coded object corresponding to the
returned API object describing the alert containing information about
the alert's location, pagegroups, and responses.

The API returns a JSON object that is formatted as follows:

```json
{
   "id": "(Active911 Alert id number)", 
   "agency": {
     "id": "(Agency id number)", 
     "uri": "(API URI to access the agency data)"
   }, 
   "place": "(Common name for the place ie Joe's Tavern)",
   "address": "(Street address for the alert)", 
   "unit": "(Subunit ie Apt G)", 
   "city": "(City alert is located in)", 
   "state": "(State alert is located in)", 
   "latitude": "(Latitude of the alert)", 
   "longitude": "(Longitude of the alert)", 
   "source": "(Source of the alert ie Battalion Chief 10)", 
   "units": "(Dispatched Units ie Truck1)", 
   "cad_code": "(Identifier Code given by CAD Software)", 
   "priority": "(Priority from CAD system)", 
   "details": "(Additional Notes)", 
   "sent": "(Time the alert was sent from our servers to Active911 devices)", 
   "description": "(Short description of the alert)", 
   "pagegroups": [
     {
       "title": "(Name of the pagegroup)",
       "prefix": "(Pagegroup prefix)"
     }
   ], 
   "map_code": "(Map Code for the alert)", 
   "received": "(Time the alert was received by our servers)", 
   "cross_street": "(Cross street of where the alert is located)", 
   "responses": [
    {
      "device": {
       "id": "(Device id of responder)", 
       "uri": "(API URI to access the device data)"
      }, 
      "timestamp": "(Timestamp of when the device responded with this response)", 
      "response": "(Name of the response action taken)"
    } 
   ]
}
```

### Map Locations

To obtain information about all the agency locations normally available via the
D4H API URL `https://access.active911.com/interface/open_api/api/locations`,
issue the following client method call:

```ruby
client.locations.index
```

Resulting data is an OpenStruct and JSON coded object corresponding to the
returned API object describing all the locations configured for the agency
and their respective URLs.

The API returns a JSON object that is formatted as follows:

```json
{
 "locations": [{
      "id": "(Active911 Location id number)", 
      "uri": "(API URI to access the location data)"
    }]
     
}
```

### Map Location

To obtain information about a specific location normally available via the
D4H API URL
`https://access.active911.com/interface/open_api/api/locations/:id`, issue
the following client method call:

```ruby
client.locations.show(location_id: location_id)
```
You will need to specify the `location_id`.

Resulting data is an OpenStruct and JSON coded object corresponding to the
returned API object describing the specific location information.

The API returns a JSON object that is formatted as follows:

```json
{
  "locations": {
    "id": "(Active911 id for this map data point)",
    "name": "(Name of this map data point)",
    "description": "(Short description of this map data point)",
    "icon_id": "(Active911 id of the icon used for this map data point)",
    "icon_color": "(Color of this map data point)",
    "latitude": "(Latitude of this map data point)",
    "longitude": "(Longitude of this map data point)",
    "location_type": "(The type of map data point)",
    "resources": [
      {
        "id": "(Resource id of responder)",
        "uri": "(API URI to access the resource data)"
      }
    ]
  }
}
```

### Map Resources

To obtain information about a specific map resource normally available via the D4H
API URL `https://access.active911.com/interface/open_api/api/resources/:id`,
issue the following client method call:

```ruby
client.resource.show(resource_id: resource_id)
```

The API returns a JSON object that is formatted as follows:
```json
{
  "resource": {
    "id": "(Active911 id for this resource)",
    "title": "(Name of the title)",
    "filename": "(Filename)",
    "extension": "(File extension)",
    "size": "(File size in bytes)",
    "details": "(Details about the file)",
    "agency": {
      "id": "(Agency id number)",
      "uri": "(API URI to access the agency data)"
    },
    "location": {
      "id": "(Location id number)",
      "uri": "(API URI to access the location data)"
    }
  }
}
```

## Limitations

* `locations` interface does not support creation (POST) yet.

## Development

To set up your development environment, run:

``` bash
git clone 
cd active911_api
bin/setup
```

You can also use the IRB console for direct access to all objects:

``` bash
bin/console
```

## Tests

To test, run:

``` bash
bin/rake
```

## [License](https://mit-license.org/)

## [Security](https://github.com/rocky-mountain-rescue/active911_api/issues)

## [Versions](https://github.com/rocky-mountain-rescue/active911_api/Versions.md)

## Credits

- Built with [Gemsmith](https://www.alchemists.io/projects/gemsmith).
- Engineered by [Pawel Osiczko](https://github.com/posiczko).
