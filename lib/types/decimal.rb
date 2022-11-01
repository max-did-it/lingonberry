require_relative "abstract_type"

module Roarm
  module Types
    class Decimal < AbstractType
      extend Helpers::Types::ArrayOf
    end
  end
end
