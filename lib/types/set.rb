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

      def set(key, values)
        connection.del(key)
        return sorted_set(key, values) if sorted

        values_to_insert = serialize(values)
        connection.sadd(key, values_to_insert)
      end

      def get(key, *args, **kwargs)
        return sorted_get(key, *args, **kwargs) if sorted

        deserialize connection.smembers(key)
      end

      def serialize(*values)
        values.flatten!
        return serializer.call(values) if serializer

        if sorted
          values.map.with_index do |value, index|
            [index.to_f, value]
          end
        else
          values.map(&:to_s)
        end
      end

      def deserialize(values)
        return patch_future_object(values) if values.is_a?(Redis::Future)
        return deserializer.call(value) if deserializer

        values
      end

      def exists?(values = nil)
      end

      private

      def sorted_set(key, *values)
        values_to_insert = serialize(values.flatten)
        connection.zadd(
          key,
          values_to_insert
        )
      end

      def sorted_get(key, *args, **kwargs)
        deserialize connection.zrange(key, 0, -1)
      end
    end
  end
end
