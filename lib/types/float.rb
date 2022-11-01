require_relative "abstract_type"

module Roarm
  module Types
    class Float < AbstractType
      extend Helpers::Types::ArrayOf
      # @param precision [Integer] define numbers after the decimal point
      def initialize(*args, precision: -1, **kwargs)
        @precision = precision
        super(*args, **kwargs)
      end
    end
  end
end
