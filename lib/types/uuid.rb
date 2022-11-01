require_relative "abstract_type"

module Roarm
  module Types
    class UUID < String
      # {Helpers::Types::DefaultOptions#extended}
      extend Helpers::Types::DefaultOptions[:length]
      extend Helpers::Types::ArrayOf
    end
  end
end
