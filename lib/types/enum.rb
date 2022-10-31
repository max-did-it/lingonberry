module Roarm
  module Types
    class Enum < AbstractType
      extend Helpers::Types::ArrayOf
      # @param keys [Hash, Array]
      #   Hash:
      #     keys - mean application layer representation of values
      #     values - mean storage layer representation of keys
      #   Array
      #     Types of elmenets not important
      #     if given additional option - store_as_string, then value will stored as string
      #     otherwise index of array element will used as representation in storage
      def initialize(keys:)
        @keys = keys
        super
      end
    end
  end
end
