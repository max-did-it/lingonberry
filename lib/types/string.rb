module Roarm
  module Types
    class String < Base
      extend Helpers::Types::ArrayOf
      # @param length [Hash<:gt, :lt, :gteq, :lteq, :eq>] bashlike comparsion keywords to limit array size
      # @return [Roarm::Types::Array] the instance of Array type
      def initialize(length: {})
        @gt = length[:gt] || -1
        @gt = length[:gt] || -1
        @gt = length[:gt] || -1
        @eq = length[:gt] || -1
        @gt, @gteq, @lt, @lteq = [-1, -1, -1, -1] if @eq.posititve?
        super
      end
    end
  end
end
