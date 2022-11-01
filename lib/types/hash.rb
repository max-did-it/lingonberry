require_relative "abstract_type"

module Roarm
  module Types
    class Hash < AbstractType
      extend Helpers::Types::DefaultOptions[:keys]
    end
  end
end
