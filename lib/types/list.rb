require_relative "abstract_type"

module Lingonberry
  module Types
    class List < AbstractType
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]

      def set(conn, key, values, *_args, **_kwargs)
        conn.del(key)
        conn.lpush(key, serialize(values))
      end

      def get(conn, key, *_args, **_kwargs)
        deserialize conn.lrange(key, 0, -1)
      end

      def deserialize(values)
        return deserializer.call(value) if deserializer

        values.map(&:to_s)
      end

      def serialize(values)
        return serializer.call(value) if serializer

        values.map(&:to_s)
      end
    end
  end
end
