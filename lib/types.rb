require_relative "helpers/types/"
require_relative "types/array"
require_relative "types/decimal"
require_relative "types/enum"
require_relative "types/float"
require_relative "types/hash"
require_relative "types/integer"
require_relative "types/list"
require_relative "types/set"
require_relative "types/stream"
require_relative "types/string"
require_relative "types/timestamp"
require_relative "types/uuid"

module Roarm
  # Namespace includes all Roarm data types
  #    used for declaring fields in models
  module Types
    class BaseClassDefinitionError < StandardError; end
  end
end
