require_relative "abstract_type"
require_relative "list"

module Lingonberry
  module Types
    def Array(type)
      Array.new(type)
    end

    # Array of elements with specified type
    # Based on Redis::List - sorted by insertion order
    # Values will coerced to source Type after extraction
    class Array < List
      # @param type [String, Boolean, Numeric, Symbol] the type of an elements
      # @return [Lingonberry::Types::Array] the instance of Array type
      def initialize(type, *args, **kwargs)
        @inner_type = type.new || self.class.instance_variable_get(:@subclass).new
        super(*args, **kwargs)
      end

      class << self
        def [](klass)
          dup.set_instance_variable(:@subclass, klass)
        end
      end

      def serialize(values)
        return serializer.call(values) if serializer

        values.map do |value|
          inner_type.serialize(value)
        end
      end

      def deserialize(values)
        return deserializer.call(values) if deserializer

        values.map do |value|
          inner_type.deserialize(value)
        end
      end

      private

      attr_reader :inner_type
    end
  end
end
