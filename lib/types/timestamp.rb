require "time"
require_relative "abstract_type"

module Lingonberry
  module Types
    class Timestamp < Integer
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]
      extend Helpers::Types::ArrayOf

      # @param value [String] the value from storage. Redis always return the string.
      # @return [Time] the mapped to Time class
      def deserialize(value)
        Time.at super(value)
      end

      def validate(value)
        serialize(value)
      end

      # @param value [String, Time, Integer] the value from storage. Redis always return the string.
      # @return [Integer] timestamp to store
      def serialize(value)
        case value
        when ::Time
          value.to_i
        when ::String
          Time.parse(value).to_i
        when ::Integer
          value
        else
          raise InvalidValueType
        end
      end
    end
  end
end
