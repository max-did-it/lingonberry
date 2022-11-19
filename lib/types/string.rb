require_relative "abstract_type"

module Lingonberry
  module Types
    class String < AbstractType
      DEFAULT_MATCHERS = %i[gt gteq lt lteq eq include exclude]

      extend Helpers::Types::ArrayOf
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]
    end
  end
end
