module Lingonberry
  class Query
    # @param sign [Symbol] bashlike sign of comparsion
    # @param value1 [<#==, #>, #>=, #<, #<= >] first value which will compared with the second one
    # @param value2 [Class<Array, String, Boolean, Symbol, Class<Numeric>>] the second value should be Ruby "primitive"
    # @return [Boolean] the comparsion of two values result
    def bash_like_comparsion(sign, value1, value2)
      case sign
      when :eq
        value1 == value2
      when :gt
        value1 > value2
      when :gteq
        value1 >= value2
      when :lt
        value1 < value2
      when :lteq
        value1 <= value2
      end
    end
  end
end
