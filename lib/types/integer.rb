require_relative "abstract_type"

module Lingonberry
  module Types
    class Integer < AbstractType
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]
      extend Helpers::Types::ArrayOf

      def deserialize(value)
        value.to_i
      end
    end
  end
end
