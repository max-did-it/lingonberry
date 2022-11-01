require_relative "abstract_type"
require_relative "list"

module Roarm
  module Types
    class Enum < AbstractType
      # {Helpers::Types::DefaultOptions#extended}
      extend Helpers::Types::DefaultOptions[:keys]
      extend Helpers::Types::ArrayOf

      attr_reader :store_as_string

      # @param store_as_string [true, false] must field enum stored as string or as number in storage
      def initialize(*args, store_as_string: false, **kwargs)
        @store_as_string = store_as_string
        super(*args, **kwargs)
      end

      def serialize(value)
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
        raise Errors::InvalidValue unless valid? value
        return value.to_sym if store_as_string

        case keys
        when ::Hash
          keys.key(value.to_i)
        when ::Array
          keys.value(value.to_i)
        end
      end

      def valid?(value)
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
