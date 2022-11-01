require_relative "abstract_type"

module Roarm
  module Types
    class Set < AbstractType
      extend Helpers::Types::DefaultOptions[:length]
      # @param sorted [true, false] should elements in set be sorted or not
      # @return [Roarm::Types::Set] the instance of Set type
      def initialize(*args, sorted: false, **kwargs)
        @sorted = sorted
        super(*args, **kwargs)
      end
    end
  end
end
