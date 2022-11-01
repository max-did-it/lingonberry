require_relative "abstract_type"

module Roarm
  module Types
    class List < AbstractType
      # {Helpers::Types::DefaultOptions#extended}
      extend Helpers::Types::DefaultOptions[:length]
    end
  end
end
