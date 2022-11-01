require_relative "abstract_type"

module Roarm
  module Types
    def Array(type)
      Array.new(type)
    end

    # Array of elements with specified type
    class Array < AbstractType
      # @param type [String, Boolean, Numeric, Symbol] the type of an elements
      # @return [Roarm::Types::Array] the instance of Array type
      def initialize(type, *args, **kwargs)
        @inner_type = type
        super(*args, **kwargs)
      end

      class << self
        def new(type = nil, length: {})
          super(type || @subclass, length: length)
        end

        def [](klass)
          dup.set_instance_variable(:@subclass, klass)
        end
      end

      private

      attr_reader :inner_type
    end
  end
end
