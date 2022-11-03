require_relative "abstract_type"

module Lingonberry
  module Types
    class UUID < String
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:length]
      extend Helpers::Types::ArrayOf
    end
  end
end
