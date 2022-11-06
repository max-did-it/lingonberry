require_relative "abstract_type"

module Lingonberry
  module Types
    class Numeric < AbstractType
      extend Helpers::Types::Options[:numeric_index]

      def set_index(key, value, context:)
        connection.zadd(
          key,
          value.to_f,
          primary_key
        )
      end
    end
  end
end
