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
    # Can't be initialized by itself, must been inherited
    # @return [Class<Lingonberry::AbstractModel>] the instance of descendant class
    def initialize
      @context = OpenStruct.new
      @context.model = self

      @fields = self.class.fields.map do |name, type, **kwargs|
        kwargs[:context] = @context
        field = Field.new(name.to_sym, type, **kwargs)
        [name.to_sym, field]
      end.to_h
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
        subclass.instance_variable_set(:@sub_fields, [])
        subclass.instance_variable_set(:@enums, [])
        subclass.instance_variable_set(:@relations, [])
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

        kwargs[:model_name] = self.name.demodulize.downcase
        field_params = [name.to_sym, type, **kwargs]
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
        raise Errors::InvalidFieldName, "Name \"#{name}\" is forbidden because intersects with model method name" if methods.include?(name) || instance_methods.include?(name)
      end

      # @param name [String, Symbol] name of the primary key
      # @return [nil] nil
      def primary_key(name)
        @primary_key = name.to_sym
        field(name, Types::PrimaryKey, sorted: true)
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
        fields.each do |_, field|
          field.save
        end
      end
    ensure
      @context.connection = nil
    end

    def new_record?
      true
    end

    private

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

    attr_reader :fields
  end
end
