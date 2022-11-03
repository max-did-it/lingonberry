require_relative "abstract_type"

module Lingonberry
  module Types
    class Numeric < AbstractType
      extend Helpers::Types::Options[:numeric_index]

      def set(conn, key, value, *args, **kwargs)
        if numeric_index
          conn.multi do |c|
            c.hset("#{kwargs[:namespace]}:#{kwargs[:field_name]}:#{}", serialize(value))
            c.zadd(to_index(value), key)
          end
        else
          super(conn, key, value, *args, **kwargs)
        end
      end

      def get(conn, key, value, *args, **kwargs)
        if numeric_index
          deserialize conn.hget(key)
        else
          super(conn, key, value, *args, **kwargs)
        end
      end

      def to_index(value)
        value.to_f
      end
    end
  end
end
