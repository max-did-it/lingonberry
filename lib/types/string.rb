require_relative "abstract_type"

module Roarm
  module Types
    class String < AbstractType
      extend Helpers::Types::ArrayOf
      # {Helpers::Types::DefaultOptions#extended}
      extend Helpers::Types::DefaultOptions[:length]
    end
  end
end
