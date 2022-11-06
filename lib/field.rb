require_relative "helpers"
require_relative "types"

module Lingonberry
  # Class for fields of {Lingonberry::AbstractModel models}.
  # Responsible for serialization/deserialization, validation,
  # store and fetch values from the storage.
  class Field
    include Helpers
    attr_reader :name, :type, :cached_value, :cache_ttl, :unsaved, :expire, :keys, :null

    # @param name [String] the name of the field
    # @param type [Lingonberry::Types::AbstractType] the type of the field
    # @param kwargs [Hash] the hash of options
    #   {Lingonberry::Types::AbstractType#initialize For options more look in subclusses of Lingonberry::Types::AbstractType}
    # @return [Lingonberry::Field] the instance of Lingonberry::Field
    def initialize(name, type, context:, cache_ttl: -1, **kwargs)
      @name = name
      @cache_ttl = cache_ttl
      @context = context

      @type = construct_type(type, kwargs)
    end

    # Create a instance of given type with the given options
    # @param type [Lingonberry::Types::AbstractType] the type of the field
    # @param kwargs [Hash] the hash of options
    #  {Lingonberry::Types::AbstractType#initialize For options more look in subclusses of Lingonberry::Types::AbstractType}
    def construct_type(type, kwargs)
      kwargs[:context] = @context
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

    # Write temp data to the storage
    def save
      return true unless @unsaved_data

      set(*@unsaved_data.args, **@unsaved_data.kwargs)
      @unsaved_data = nil
      true
    end

    def unsaved?
      !@unsaved_data.nil?
    end

    # Temporarily save data
    def store(*args, **kwargs)
      @unsaved_data = OpenStruct.new({
        args: args,
        kwargs: kwargs
      })
    end

    def get(*args, **kwargs)
      if cache_ttl.positive?
        return cached_value if cache_valid?

        @cached_at = Time.now
        @cached_value = type.get(key, *args, **kwargs)
      else
        type.get(key, *args, **kwargs)
      end
    end

    def exists?
      connection.exists?(key)
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

    def cache_valid?
      return false unless @cached_at

      (Time.now - @cached_at) < cache_ttl
    end

    # immediately save data to the storage
    def set(*args, **kwargs)
      type.set(key, *args, **kwargs)
      kwargs[:index_key] = index_key
      type.post_set(key, *args, **kwargs)
    end

    private

    def connection
      @context.transaction || @context.connection
    end

    # Making a key according field name and model name
    # @return [String] the key on which value is stored
    def key(primary_key: @context.instance.primary_key.get)
      "lingonberry:#{@context.model_name}:#{name}:#{primary_key}"
    end

    def index_key
      "lingonberry:#{@context.model_name}:#{name}"
    end
  end
end
