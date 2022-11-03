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
        field = make_field(name, type, **kwargs)
        [field.to_sym, field]
      end
      @fields = @fields.to_h
      @context.feilds = fields
      @context.namespace = model_namespace
    end

    class << self
      attr_accessor :fields, :associations

      def new
        raise Errors::AbstractClass if superclass == Object

        super
      end

      def with_connection
        Lingonberry.connection do |conn|
          yield conn if block_given?
        end
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

      # @param name [::String, ::Symbol] the name of the field.
      # @param type [Lingonberry::Types::AbstractType] class data type of the field
      # @param kwargs [Hash] array of kwargs
      #   For available options look in Lingonberry::Field documentations.
      # @return [nil]
      def field(name, type, **kwargs)
        f = [name, type, kwargs]
        @fields.push(f)
        define_method(name.to_sym) do |*jargs, **jkwargs|
          get(fields[__method__], *jargs, **jkwargs)
        end

        define_method("#{name}=") do |*jargs, **jkwargs|
          field_name = __method__.to_s.delete("=").to_sym
          set(fields[field_name], *jargs, **jkwargs)
        end
        nil
      end

      # @param name [String, Symbol] name of the field
      # @param type [Lingonberry::Types::AbstractType] type of field
      # @return [nil] nil
      def primary_key(name, type)
        @primary_key = name
        field(name, type, uniq: true)
      end

      # Find the data which matches the conditions
      # @param kwargs [Hash] conditions to filter the data
      # @return [Relation] the instance of relation
      def where(**kwargs)
      end
    end

    def save!
      # pass
    end

    private

    attr_reader :fields

    def with_connection
      self.class.with_connection do |conn|
        yield conn if block_given?
      end
    end

    def get(field, *args, **kwargs)
      with_connection do |conn|
        @context.connection = conn
        field.fetch *args, **kwargs
      end
    ensure
      @context.connection = nil
    end

    def set(field, *args, **kwargs)
      with_connection do |conn|
        @context.connection = conn
        field.set(*args, **kwargs)
      end
    ensure
      @context.connection = nil
    end

    # Making a key according to given field in the model
    # @param field [#to_s] the name of the field
    # @return [String] the key on which value is stored
    def model_namespace
      "lingonberry:#{self.class.name.downcase}"
    end

    def make_field(name, type, **kwargs)
      field = Field.new(@context, name, type, **kwargs)
    end
  end
end
