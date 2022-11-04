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
    def initialize(name, type, model_name:, **kwargs)
      @name = name
      @model_name = model_name
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

    def set(*args, **kwargs)
      if Lingonberry.config.safe_mode
        @temp_key = key
        @temp_args = args
        @temp_kwargs = kwargs
        @unsaved = true
      else
        store(key, *args, **kwargs)
      end
    end

    def store(key, *args, **kwargs)
      Lingonberry.connection do |conn|
        type.set(conn, key, *args, **kwargs)
        @value = nil
      end
    end

    def set_expire_key(key, conn: nil)
      return unless expire
      return conn.expire(key, expire) if conn

      Lingonberry.connection do |connection|
        connection.expire(key, expire)
      end
    end

    def store_unsaved(validate:)
      raise Errors::InvalidaValue if validate && !valid?

      store(@temp_key, *@temp_args, **@temp_kwargs)
      @unsaved = false
      @temp_key = nil
      @temp_args = nil
      @temp_kwargs = nil
    end

    def get(*args, **kwargs)
      Lingonberry.connection do |conn|
        if Lingonberry.config.safe_mode
          @value ||= type.get(conn, key, *args, **kwargs)
          @value
        else
          type.get(conn, key, *args, **kwargs)
        end
      end
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
