require_relative "abstract_type"

module Roarm
  module Types
    class String < AbstractType
      extend Helpers::Types::ArrayOf
      extend Helpers::Types::DefaultOptions[:length]
    end
  end
end
