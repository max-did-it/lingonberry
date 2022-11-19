module Lingonberry
  # Namespace for all gem errors
  module Errors
    class BaseError < StandardError; end

    # Used to raise a error when method called in abstract class
    class AbstractClass < BaseError; end

    # Used to raise a error when noone argument is given
    class NoArgsGiven < BaseError; end

    class UnknownType < BaseError; end

    class InvalidValue < BaseError; end

    class InvalidTypeArrayOf < BaseError; end

    class BaseClassDefinitionError < BaseError; end

    class DirectMethodCall < BaseError; end

    class UnexpectedError < BaseError; end

    class UnknownKey < BaseError; end

    class InvalidFieldName < BaseError; end

    class SavingGoneWrong < BaseError; end

    class DuplicatedFieldName < BaseError; end

    class PrimaryKeyImmutable < BaseError; end

    class UnknownBaseClass < BaseError; end

    class RecordNotFound < BaseError; end

    class ScriptExtensionIsNotLua < BaseError; end
  end
end
