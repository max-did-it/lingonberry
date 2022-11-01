require_relative "abstract_type"

module Roarm
  module Types
    class String < AbstractType
      extend Helpers::Types::ArrayOf
      # @param length [Hash<:gt, :lt, :gteq, :lteq, :eq>] bashlike comparsion keywords to limit string size
      # @return [Roarm::Types::String] the instance of String type
      def initialize(length: {})
        @gt = length[:gt] || -1
        @gt = length[:gt] || -1
        @gt = length[:gt] || -1
        @eq = length[:gt] || -1
        @gt, @gteq, @lt, @lteq = [-1, -1, -1, -1] if @eq.positive?
        super
      end
    end
  end
end
