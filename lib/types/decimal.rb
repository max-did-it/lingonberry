require_relative "abstract_type"

module Lingonberry
  module Types
    class Decimal < AbstractType
      extend Helpers::Types::ArrayOf
    end
  end
end
