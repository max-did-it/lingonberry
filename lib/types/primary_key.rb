require_relative "string"

module Lingonberry
  module Types
    class PrimaryKey < Set
      generator do |_instance|
        SecureRandom.uuid
      end

      def set(key, value, **kwargs)
        connection.srem key, kwargs[:old_value] if kwargs[:old_value]
        values_to_insert = serialize(value)
        connection.sadd(key, values_to_insert)
      end
    end
  end
end
