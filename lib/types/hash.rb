module Roarm
  module Types
    class Hash < Base
      # @param keys [Array] restricts allowed keys to store in hash
      def initialize(keys: nil)
        @keys = keys
        super
      end
    end
  end
end
