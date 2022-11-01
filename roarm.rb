Bundler.require(:development)
require_relative "lib/field"
require_relative "lib/query"
require_relative "lib/abstract_model"
require_relative "lib/relation"
require_relative "lib/migration"
require_relative "lib/configuration"
require_relative "lib/errors"

Roarm.configure
require_relative "lib/connection"

module Roarm
end
