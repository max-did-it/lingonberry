require_relative "field"

module Lingonberry
  # Class for fields of {Lingonberry::AbstractModel models}.
  # Responsible for serialization/deserialization, validation,
  # store and fetch values from the storage.
  class PrimaryKey < Field
    def initialize(name, **kwargs)
      super(name, Types::PrimaryKey, **kwargs)
    end

    def key(*_args, **_kwargs)
      "lingonberry:#{@context.model_name}:#{name}"
    end

    def set(value, *args, **kwargs)
      @context.connection.multi do
        @context.instance.send(:fields).each_value do |field|
          old_key = field.send(:key)
          new_key = field.send(:key, primary_key: value)
          next unless @context.connection.exists?(old_key)

          @context.connection.rename(old_key, new_key)
        end
        super(value, *args, **kwargs)
        @cached_value = value
      end
    end

    def get(*_args, **_kwargs)
      @cached_value
    end
  end
end
