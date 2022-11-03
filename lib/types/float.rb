require_relative "abstract_type"

module Lingonberry
  module Types
    class Float < AbstractType
      extend Helpers::Types::ArrayOf

      attr_reader :precision

      # @param precision [Integer] define numbers after the decimal point
      def initialize(*args, precision: -1, **kwargs)
        @precision = precision
        super(*args, **kwargs)
      end

      def serialize(value)
        return serializer.call(value) if serializer
        return value.to_f.to_s if precision.negative?

        value.to_f.truncate(precision).to_s
      end

      def deserialize(value)
        return deserializer.call(value) if deserializer

        value.to_f
      end
    end
  end
end
