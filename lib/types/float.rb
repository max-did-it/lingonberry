require_relative "abstract_type"

module Roarm
  module Types
    class Float < AbstractType
      extend Helpers::Types::ArrayOf
      # @param precision [Integer] define numbers after the decimal point
      def initialize(precision: -1)
        @precision = precision
        super
      end
    end
  end
end
