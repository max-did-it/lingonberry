require_relative "abstract_type"
require_relative "list"

module Lingonberry
  module Types
    class Enum < AbstractType
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:keys]
      extend Helpers::Types::ArrayOf

      attr_reader :store_as_string

      # @param store_as_string [true, false] must field enum stored as string or as number in storage
      def initialize(*args, store_as_string: false, **kwargs)
        @store_as_string = store_as_string
        super(*args, **kwargs)
      end

      def serialize(value)
        return serializer.call(value) if serializer

        raise Errors::InvalidValue unless valid? value
        return value.to_s if store_as_string

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
        return value.to_sym if store_as_string

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
