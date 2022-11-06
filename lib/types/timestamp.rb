require "time"
require_relative "abstract_type"

module Lingonberry
  module Types
    class Timestamp < Float
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]
      extend Helpers::Types::ArrayOf

      # @param value [String] the value from storage. Redis always return the string.
      # @return [Time] the mapped to Time class
      def deserialize(value)
        return patch_future_object(value) if value.is_a?(Redis::Future)
        return deserializer.call(value) if deserializer

        Time.at super(value)
      end

      def validate(value)
        serialize(value)
      end

      # @param value [String, Time, Integer] the value from storage. Redis always return the string.
      # @return [Integer] timestamp to store
      def serialize(value)
        return serializer.call(value) if serializer

        case value
        when ::Time
          value.to_f
        when ::String
          Time.parse(value).to_f
        when ::Integer
          value.to_f
        when ::Float
          value
        else
          raise InvalidValueType
        end
      end
    end
  end
end
