module Lingonberry
  # Namespace for all gem errors
  module Errors
    # Used to raise a error when method called in abstract class
    class AbstractClass < StandardError; end

    # Used to raise a error when noone argument is given
    class NoArgsGiven < StandardError; end

    class UnknownType < StandardError; end

    class InvalidValue < StandardError; end

    class InvalidTypeArrayOf < StandardError; end

    class BaseClassDefinitionError < StandardError; end

    class DirectMethodCall < StandardError; end

    class UnexpectedError < StandardError; end

    class UnknownKey < StandardError; end
  end
end
