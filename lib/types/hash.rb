require_relative "abstract_type"

module Roarm
  module Types
    class Hash < AbstractType
      # {Helpers::Types::DefaultOptions#extended}
      extend Helpers::Types::DefaultOptions[:keys]
    end
  end
end
