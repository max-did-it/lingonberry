module Roarm
  module Types
    def Array(type)
      Array.new(type)
    end

    # Array of elements with specified type
    class Array < AbstractType
      # @param type [String, Boolean, Numeric, Symbol] the type of an elements
      # @param length [Hash<:gt, :lt, :gteq, :lteq, :eq>] bashlike comparsion keywords to limit array size
      # @return [Roarm::Types::Array] the instance of Array type
      def initialize(type, length: {})
        @inner_type = type
        @gt = length[:gt] || -1
        @gt = length[:gt] || -1
        @gt = length[:gt] || -1
        @eq = length[:gt] || -1
        @gt, @gteq, @lt, @lteq = [-1, -1, -1, -1] if @eq.posititve?
        super
      end

      private

      attr_reader :inner_type
    end
  end
end
