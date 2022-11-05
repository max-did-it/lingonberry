require_relative "abstract_type"

module Lingonberry
  module Types
    class Numeric < AbstractType
      extend Helpers::Types::Options[:numeric_index]

      def set_index(conn, key, value, context:)
        conn.zadd(
          key,
          value.to_f,
          primary_key
        )
      end
    end
  end
end
