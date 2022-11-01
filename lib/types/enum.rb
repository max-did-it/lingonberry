require_relative "abstract_type"

module Roarm
  module Types
    class Enum < AbstractType
      extend Helpers::Types::DefaultOptions[:keys]
      extend Helpers::Types::ArrayOf
      # @param keys [Hash, Array]
      #   Hash:
      #     keys - mean application layer representation of values
      #     values - mean storage layer representation of keys
      #   Array
      #     Types of elmenets not important
      #     if given additional option - store_as_string, then value will stored as string
      #     otherwise index of array element will used as representation in storage
      # @param store_as_string [true, false] must field enum stored as string or as number in storage
      def initialize(keys:, store_as_string: false)
        @store_as_string = store_as_string
        @keys = keys
        super
      end
    end
  end
end
