require_relative "abstract_type"

module Lingonberry
  module Types
    class Numeric < AbstractType
      DEFAULT_MATCHERS = %i[gt gteq lt lteq eq]
      extend Helpers::Types::Options[:numeric_index]

      def post_set(key, value, *args, index_key: nil, **kwargs)
        set_index(@context.instance.primary_key.get, index_key, value)
      ensure
        super(key, value, *args, **kwargs)
      end

      def set_index(primary_key, index_key, value)
        connection.zadd(index_key, serialize(value), primary_key)
      end
    end
  end
end
