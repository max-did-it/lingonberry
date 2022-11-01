require_relative "abstract_type"

module Roarm
  module Types
    class UUID < String
      extend Helpers::Types::ArrayOf
      extend Helpers::Types::DefaultOptions[:length]
    end
  end
end
