require_relative "abstract_type"

module Lingonberry
  module Types
    class List < AbstractType
      DEFAULT_MATCHERS = %i[include exclude]
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]

      def set(key, values, *_args, **_kwargs)
        connection.del(key)
        values_to_insert = serialize(values)
        connection.lpush(key, values_to_insert)
      end

      def get(key, *_args, **_kwargs)
        deserialize connection.lrange(key, 0, -1)
      end

      def deserialize(values)
        return patch_future_object(values) if values.is_a?(Redis::Future)
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
