require_relative "field"
require_relative "primary_key"

module Lingonberry
  # Base class to create a Models
  # Usage example:
  # ```ruby
  # class User < AbstractModel
  #   field :name, String, length: { gteq: 3, lteq: 50 }
  #   field :age, Integer
  #   field :email, String
  #   field :phone, String, length: { eq: 10 }, validator: ->(phone) { phone.match? /^\([0-9]{3}\)[0-9]{3}-[0-9]{4}$/ }
  #
  #   field :created_at, Timestamp
  # end
  # user = User.find(123)
  # users = User.where(age: { gteq: 18, lteq: 30}, created_at: { gt: 3.days.ago })
  # ```
  class AbstractModel
    attr_reader :fields, :primary_key
    # Can't be initialized by itself, must been inherited
    # @param kwargs [Hash] hash of values that would be assigned to the fields. to save that values call {#save!} or {#save}
    # @return [Class<Lingonberry::AbstractModel>] the instance of descendant class
    def initialize(**kwargs)
      @context = OpenStruct.new
      @context.model_name = self.class.name.demodulize.downcase
      @context.instance = self

      primary_key_name = self.class.instance_variable_get(:@primary_key)

      @fields = self.class.fields.map do |name, type, jkwargs|
        jkwargs[:context] = @context
        field = if primary_key_name == name
          @primary_key = PrimaryKey.new(name.to_sym, **jkwargs)
        else
          Field.new(name.to_sym, type, **jkwargs)
        end
        [name.to_sym, field]
      end.to_h

      return unless kwargs.any?

      kwargs.each do |field_name, value|
        send("#{field_name}=", value)
      end
    end

    class << self
      attr_accessor :fields, :associations

      def new(*args, **kwargs)
        raise Errors::AbstractClass if superclass == Object

        super(*args, **kwargs)
      end

      # Preload class instance variables for descendants when model inherited from Lingonberry::AbstractModel or from any descendants
      # @param subclass [Lingonberry::AbstractModel]
      def inherited(subclass)
        subclass.instance_variable_set(:@fields, [])
        subclass.instance_variable_set(:@primary_key, nil)
        super
      end

      # Defines a meta read/write accessors by the name of field
      #   for instances
      # @param args [Array] array of arguments.
      #   For available arguments look in Lingonberry::Field documentations.
      # @param kwargs [Hash] array of kwargs
      #   For available options look in Lingonberry::Field documentations.
      # @return [nil]
      def field(name, type, **kwargs)
        field_name_valid?(name.to_sym)

        field_params = [name.to_sym, type, kwargs]
        @fields.push(field_params)

        define_method(name.to_sym) do |*jargs, **jkwargs|
          get fields[__method__], *jargs, **jkwargs
        end

        define_method("#{name.to_sym}=") do |*jargs, **jkwargs|
          field_name = __method__.to_s.delete("=").to_sym
          store fields[field_name], *jargs, **jkwargs
        end

        nil
      end

      def field_name_valid?(name)
        if methods.include?(name) || instance_methods.include?(name)
          raise Errors::InvalidFieldName,
            "Name \"#{name}\" is forbidden because intersects with model method name"
        end
        raise Errors::DuplicatedFieldName, "Name \"#{name}\" have been declared in #{self}" if fields.find do |f|
                                                                                                 f[0] == name
                                                                                               end
      end

      # @param name [String, Symbol] name of the primary key
      # @return [nil] nil
      def primary_key(name, *_args, **_kwargs)
        @primary_key = name.to_sym
        field(name, nil, sorted: false)
      end

      # Find the data which matches the conditions
      # @param kwargs [Hash] conditions to filter the data
      # @return [Relation] the instance of relation
      def where(**kwargs)
      end
    end

    def save!
      save
    end

    def save
      return with_connection(&method(__method__)) unless context_connection

      set_primary_key if new_record?
      fields.each do |_, field|
        field.save
      end
      self
    end

    def new_record?
      return with_connection(&method(__method__)) unless context_connection

      !primary_key.exists?
    end

    def unsaved?
      fields.any? { |_, f| f.unsaved? }
    end

    private

    def set_primary_key
      primary_key.set(
        primary_key.get || primary_key.type.generator.call(self)
      )
    end

    def get(field, *args, **kwargs)
      unless context_connection
        return with_connection [field, args, kwargs], &method(__method__)
      end
      field.get(*args, **kwargs)
    end

    def store(field, *args, **kwargs)
      field.store(*args, **kwargs)
    end

    def with_connection(args = [], transaction: false, &block)
      return unless block

      Lingonberry.connection do |conn|
        @context.connection = conn
        return transaction(*args, &block) if transaction

        block.call(*args)
      end
    ensure
      @context.connection = @context.transaction = nil
    end

    def transaction(args = [], &block)
      return unless block

      @context.connection.multi do |transaction|
        @context.transaction = transaction
        block.call(*args)
      end
    end

    def context_connection
      @context.transaction || @context.connection
    end
  end
end
