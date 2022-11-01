require_relative "helpers"
require_relative "types"

module Roarm
  # Class for fields of {Roarm::AbstractModel models}.
  # Responsible for serialization/deserialization, validation,
  # store and fetch values from the storage.
  class Field
    include Helpers
    attr_reader :name, :type, :keys, :index, :expire, :null

    # @param name [String] the name of the field
    # @param type [Roarm::Types::AbstractType] the type of the field
    # @param null [true, false] the parameter responded might field accepts nil values
    # @param index [true, false] the parameter used to create secondary indexes in Redis for your model
    # @param uniq [true, false] the parameter used to prevent duplication of the value, all records will have unique values in this field
    # @param validator [#call] the validator which accepts value as parameter
    #   should return result as array with 2 elements
    #   example: [false, ["isn't integer"]]
    #   where first element is result of validation, second is array of errors
    # @param kwargs [Hash] the hash of options
    #   {Roarm::Types::AbstractType#initialize For options more look in subclusses of Roarm::Types::AbstractType}
    # @return [Roarm::Field] the instance of Roarm::Field
    def initialize(name, type, null: true, index: false, expire: nil, validator: nil, uniq: false, **kwargs)
      @name = name
      @type = construct_type(type, kwargs)
      @index = index
      @expire = expire
      @validator = validator
      @uniq = uniq
      @null = null || @type.null
    end

    # Create a instance of given type with the given options
    # @param type [Roarm::Types::AbstractType] the type of the field
    # @param kwargs [Hash] the hash of options
    #  {Roarm::Types::AbstractType#initialize For options more look in subclusses of Roarm::Types::AbstractType}
    def construct_type(type, kwargs)
      case type
      when ::Array
        raise InvalidTypeArrayOf if type.count > 1

        Types::Array.new(type.first, **kwargs)
      when Types::Array
        raise InvalidTypeArrayOf, "Example definition Array Of is: field :array_field_name, [Integer]"
      when Types::AbstractType
        type.new(**kwargs)
      else
        raise UnknownType, "#{type} unknown"
      end
    end

    def set_instance
      direct_call_protection
    end

    def set(key, *args, **kwargs)
      Roarm::Connection.with do |conn|
        type.set(key, conn, *args, **kwargs)
      end
    end

    def fetch(key)
      Roarm::Connection.with do |conn|
        type.fetch(key, conn)
      end
    end

    def valid?
      true
    end

    def inspect
      name
    end

    def to_s
      name
    end

    def to_sym
      name.to_sym
    end

    class UnknownType < StandardError; end

    class InvalidTypeArrayOf < StandardError; end
  end
end
