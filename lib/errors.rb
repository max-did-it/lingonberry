module Roarm
  # Namespace for all gem errors
  module Errors
    # Used to raise a error when method called in abstract class
    class AbstractClass < StandardError; end

    # Used to raise a error when noone argument is given
    class NoArgsGiven < StandardError; end

    class UnknownType < StandardError; end

    class InvalidaValue < StandardError; end

    class InvalidTypeArrayOf < StandardError; end

    class BaseClassDefinitionError < StandardError; end

    class DirectMethodCall < StandardError; end
  end
end
