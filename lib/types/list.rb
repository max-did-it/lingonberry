require_relative "abstract_type"

module Roarm
  module Types
    class List < AbstractType
      # {Helpers::Types::DefaultOptions#extended}
      extend Helpers::Types::DefaultOptions[:length]

      def set(conn, key, values, *_args, **_kwargs)
        conn.del(key)
        conn.lpush(key, serialize(values))
      end

      def get(conn, key, *_args, **_kwargs)
        deserialize conn.lrange(key, 0, -1)
      end

      def serialize(values)
        values.map(&:to_s)
      end
    end
  end
end
