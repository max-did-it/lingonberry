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
    # @return [Class<Lingonberry::AbstractModel>] the instance of descendant class
    def initialize(**kwargs)
      @new_record = kwargs.delete(:new_record) || true

      @context = OpenStruct.new
      @context.model_name = self.class.name.demodulize.downcase
      @context.instance = self

      primary_key_name = self.class.instance_variable_get(:@primary_key)

      @fields = self.class.fields.map do |name, type, **jkwargs|
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

      def new
        raise Errors::AbstractClass if superclass == Object

        super
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
      def primary_key(name)
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
      with_connection do |connection|
        @context.connection = connection

        set_primary_key if new_record?

        fields.each do |_, field|
          field.save
        end
      end
      @new_record = false if new_record?
      self
    ensure
      @context.connection = nil
    end

    def new_record?
      @new_record
    end

    def unsaved?
      fields.any? { |_, f| f.unsaved? }
    end

    private

    def set_primary_key
      primary_key.set(
        primary_key.type.generator.call(self)
      )
    end

    def get(field, *args, **kwargs)
      with_connection do |connection|
        @context.connection = connection
        field.get(*args, **kwargs)
      end
    ensure
      @context.connection = nil
    end

    def store(field, *args, **kwargs)
      field.store(*args, **kwargs)
    ensure
      @context.connection = nil
    end

    def with_connection(transaction: false, &block)
      return unless block

      Lingonberry.connection do |conn|
        if transaction
          transaction(conn, &block)
        else
          block.call(conn)
        end
      end
    end

    def transaction(connection, &block)
      return unless block

      connection.multi do |conn|
        block.call(conn)
      end
    end
  end
end
