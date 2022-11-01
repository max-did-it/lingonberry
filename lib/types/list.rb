require_relative "abstract_type"

module Roarm
  module Types
    class List < AbstractType
      extend Helpers::Types::DefaultOptions[:length]
    end
  end
end
