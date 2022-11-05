require_relative "string"

module Lingonberry
  module Types
    class PrimaryKey < Set
      generator do |_instance|
        SecureRandom.uuid
      end

      def set(conn, key, value, **kwargs)
        conn.srem key, kwargs[:old_value] if kwargs[:old_value]
        push(conn, key, value, **kwargs)
      end
    end
  end
end
