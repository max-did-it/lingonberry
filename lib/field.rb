require_relative "helpers"
require_relative "types"

module Lingonberry
  # Class for fields of {Lingonberry::AbstractModel models}.
  # Responsible for serialization/deserialization, validation,
  # store and fetch values from the storage.
  class Field
    include Helpers
    attr_reader :name, :type, :unsaved, :expire, :keys, :null

    # @param name [String] the name of the field
    # @param type [Lingonberry::Types::AbstractType] the type of the field
    # @param kwargs [Hash] the hash of options
    #   {Lingonberry::Types::AbstractType#initialize For options more look in subclusses of Lingonberry::Types::AbstractType}
    # @return [Lingonberry::Field] the instance of Lingonberry::Field
    def initialize(name, type, model_name:, context:, **kwargs)
      @name = name
      @model_name = model_name
      @context = context
      @type = construct_type(type, kwargs)
    end

    # Create a instance of given type with the given options
    # @param type [Lingonberry::Types::AbstractType] the type of the field
    # @param kwargs [Hash] the hash of options
    #  {Lingonberry::Types::AbstractType#initialize For options more look in subclusses of Lingonberry::Types::AbstractType}
    def construct_type(type, kwargs)
      case type
      when ::Array
        raise Errors::InvalidTypeArrayOf if type.count > 1

        Types::Array.new(type.first, **kwargs)
      when Types::Array
        raise Errors::InvalidTypeArrayOf, "Example definition Array Of is: field :array_field_name, [Integer]"
      when Types::AbstractType
        type.new(**kwargs)
      else
        raise Errors::UnknownType, "#{type} unknown"
      end
    end

    def set_instance
      direct_call_protection
    end

    # immediately save data to the storage
    def set(*args, **kwargs)
      type.set(
        @context.connection,
        key,
        *args,
        **kwargs
      )
    end

    # Write temp data to the storage
    def save
      return true unless @unsaved_data

      result = type.set(
        @context.connection,
        key,
        *@unsaved_data.args,
        **@unsaved_data.kwargs
      )
      raise Errors::SavingGoneWrong, "#{@model_name}##{name} saving gone wrong with values #{@unsaved_data.to_h}" unless result

      @unsaved_data = nil
    end

    # Temporarily save data
    def store(*args, **kwargs)
      @unsaved_data = OpenStruct.new({
        args: args,
        kwargs: kwargs
      })
    end

    def get(*args, **kwargs)
      type.get(@context.connection, key, *args, **kwargs)
    end

    def valid?
      true
    end

    def inspect
      name
    end

    def to_s
      name.to_s
    end

    def to_sym
      name.to_sym
    end

    # Making a key according field name and model name
    # @return [String] the key on which value is stored
    def key
      "lingonberry:#{@model_name}:#{name}"
    end
  end
end
