module Roarm
  module Types
    class Float < Base
      extend Helpers::Types::ArrayOf
      # @param precision [Integer] define numbers after the decimal point
      def initialize(precision: -1)
        @precision = precision
        super
      end
    end
  end
end
