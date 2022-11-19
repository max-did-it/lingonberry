require_relative "field"

module Lingonberry
  # Class for fields of {Lingonberry::AbstractModel models}.
  # Responsible for serialization/deserialization, validation,
  # store and fetch values from the storage.
  class PrimaryKey < Field
    TYPE = Types::PrimaryKey

    def initialize(name, **kwargs)
      super(name, TYPE, **kwargs)
    end

    def key(*_args, **_kwargs)
      "lingonberry:#{@context.model_name}:#{name}"
    end

    def self.key(model_name, field_name)
      "lingonberry:#{model_name}:#{field_name}"
    end

    def set(value, *args, **kwargs)
      keys = @context.instance.fields.values.map { |field| field.send(:key) }

      @context.connection.watch(key, *keys)
      transaction_result = @context.connection.multi do |transaction|
        @context.transaction = transaction
        @context.instance.fields.each_value do |field|
          old_key = field.send(:key)
          new_key = field.send(:key, primary_key: value)
          next unless @context.connection.exists?(old_key)

          transaction.rename(old_key, new_key)
        end
        super(value, *args, **kwargs)
      end
      @context.connection.unwatch

      raise SavingGoneWrong if transaction_result.empty?

      @cached_value = value
    ensure
      @context.transaction = nil
    end

    def get(*_args, **_kwargs)
      @cached_value
    end

    def exists?
      type.exists?(@cached_value)
    end
  end
end
