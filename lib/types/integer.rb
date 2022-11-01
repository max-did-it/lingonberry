require_relative "abstract_type"

module Roarm
  module Types
    class Integer < AbstractType
      extend Helpers::Types::DefaultOptions[:length]
      extend Helpers::Types::ArrayOf

      def deserialize(value)
        value.to_i
      end
    end
  end
end
