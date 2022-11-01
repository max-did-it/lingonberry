require_relative "abstract_type"

module Roarm
  module Types
    class Hash < AbstractType
      extend Helpers::Types::DefaultOptions[:keys]
      # @param keys [Array] restricts allowed keys to store in hash
      def initialize(keys: nil)
        @keys = keys
        super
      end
    end
  end
end
