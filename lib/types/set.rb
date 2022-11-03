require_relative "abstract_type"

module Lingonberry
  module Types
    class Set < AbstractType
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]

      attr_reader :sorted

      # @param sorted [true, false] should elements in set be sorted or not
      # @return [Lingonberry::Types::Set] the instance of Set type
      def initialize(*args, sorted: false, **kwargs)
        @sorted = sorted
        super(*args, **kwargs)
      end

      def set(conn, key, *values)
        conn.del(key)
        return sorted_set(conn, key, *values) if sorted

        conn.sadd key, serialize(values.flatten!)
      end

      def get(conn, key, *args, **kwargs)
        return sorted_get(conn, key, *args, **kwargs) if sorted

        deserialize conn.smembers(key)
      end

      def serialize(values)
        values.map(&:to_s)
      end

      def deserialize(values)
        values
      end

      private

      def sorted_set(conn, key, *values)
        conn.zadd(
          key,
          serialize(values.flatten).map.with_index do |value, index|
            [index.to_f, value]
          end
        )
      end

      def sorted_get(conn, key, *args, **kwargs)
        deserialize conn.zrange(key, 0, -1)
      end
    end
  end
end
