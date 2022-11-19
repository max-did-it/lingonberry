require_relative "abstract_type"

module Lingonberry
  module Types
    class SortedSet < AbstractType
      DEFAULT_MATCHERS = %i[include exclude]
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]

      def set(key, values)
        connection.del(key)
        values_to_insert = serialize(values.flatten)
        connection.zadd(
          key,
          values_to_insert
        )
      end

      def get(key, *args, **kwargs)
        deserialize connection.zrange(key, 0, -1)
      end

      def serialize(*values)
        values.flatten!
        return serializer.call(values) if serializer

        values.map.with_index do |value, index|
          [index.to_f, value]
        end
      end

      def deserialize(values)
        return patch_future_object(values) if values.is_a?(Redis::Future)
        return deserializer.call(value) if deserializer

        values
      end

      def exists?(values = nil)
      end
    end
  end
end
