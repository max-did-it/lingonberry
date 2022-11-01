require_relative "abstract_type"

module Roarm
  module Types
    class Enum < AbstractType
      extend Helpers::Types::DefaultOptions[:keys]
      extend Helpers::Types::ArrayOf
      # @param store_as_string [true, false] must field enum stored as string or as number in storage
      def initialize(*args, store_as_string: false, **kwargs)
        @store_as_string = store_as_string
        super(*args, **kwargs)
      end
    end
  end
end
