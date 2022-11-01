require_relative "abstract_type"

module Roarm
  module Types
    class List < AbstractType
      # @param length [Hash<:gt, :lt, :gteq, :lteq, :eq>] bashlike comparsion keywords to limit list size
      # @return [Roarm::Types::List] the instance of List type
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
