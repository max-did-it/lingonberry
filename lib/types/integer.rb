require_relative "abstract_type"

module Lingonberry
  module Types
    class Integer < Numeric
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]
      extend Helpers::Types::ArrayOf

      def deserialize(value)
        return deserializer.call(value) if deserializer

        value.to_i
      end
    end
  end
end
