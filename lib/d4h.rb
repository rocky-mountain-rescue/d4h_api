# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.then do |loader|
  loader.inflector.inflect "d4h" => "D4H"
  loader.setup
end

# Main namespace.
module D4H
  autoload :Client, "d4h/client"
  autoload :Error, "d4h/error"
  autoload :Model, "d4h/model"
  autoload :Resource, "d4h/resource"

  autoload :Event, "d4h/models/event"
  autoload :EventResource, "d4h/resources/event"
  autoload :Team, "d4h/models/team"
  autoload :TeamResource, "d4h/resources/team"
end
