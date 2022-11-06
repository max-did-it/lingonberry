require_relative "numeric"

module Lingonberry
  module Types
    class Integer < Numeric
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]
      extend Helpers::Types::ArrayOf

      def deserialize(value)
        return patch_future_object(value) if value.is_a?(Redis::Future)
        return deserializer.call(value) if deserializer

        value.to_i
      end
    end
  end
end
