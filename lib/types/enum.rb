require_relative "abstract_type"
require_relative "list"
require_relative "numeric"

module Lingonberry
  module Types
    class Enum < Numeric
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:keys, :null]
      extend Helpers::Types::ArrayOf

      def [](key)
        case keys
        when ::Hash
          keys[key.to_sym]
        when ::Array
          keys.index(key.to_sym)
        end
      end

      def serialize(value)
        return serializer.call(value) if serializer
        raise Errors::InvalidValue unless valid? value

        case keys
        when ::Hash
          keys[value.to_sym]
        when ::Array
          keys.index(value.to_sym)
        end
      end

      def deserialize(value)
        return patch_future_object(value) if value.is_a?(Redis::Future)
        return deserializer.call(value) if deserializer

        case keys
        when ::Hash
          keys.key(value.to_i)
        when ::Array
          keys[value.to_i]
        end
      end

      def valid?(value)
        return false unless value.respond_to?(:to_sym)

        case keys
        when ::Hash
          !keys[value.to_sym].nil?
        when ::Array
          keys.include?(value.to_sym)
        else
          raise Errors::UnexpectedError
        end
      end
    end
  end
end
