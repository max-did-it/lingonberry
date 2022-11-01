require_relative "abstract_type"

module Roarm
  module Types
    class Set < AbstractType
      # @param length [Hash<:gt, :lt, :gteq, :lteq, :eq>] bashlike comparsion keywords to limit set size
      # @param sorted [true, false] should elements in set be sorted or not
      # @return [Roarm::Types::Set] the instance of Set type
      def initialize(length: {}, sorted: false)
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
