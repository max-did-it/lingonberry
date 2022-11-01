require_relative "abstract_type"

module Roarm
  module Types
    class Integer < AbstractType
      extend Helpers::Types::ArrayOf
    end
  end
end
