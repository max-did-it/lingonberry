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
      @fields = self.class.fields.map { |f| [f.to_sym, f] }.to_h
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
      def field(*args, **kwargs)
        field_instance = Field.new(*args, **kwargs)
        @fields.push(field_instance) if field_instance.valid?

        define_method(field_instance.to_sym) do
          fields[__method__].fetch field_key(__method__)
        end

        define_method("#{field_instance}=") do |*jargs, **jkwargs|
          field_name = __method__.to_s.delete("=").to_sym
          fields[field_name].set(field_key(field_name), *jargs, **jkwargs)
        end

        nil
      end

      # @param name [String, Symbol] name of the primary key
      # @return [nil] nil
      def primary_key(name)
        @primary_key = name
        field(name, Types::PrimaryKey, sorted: true)
      end

      # Find the data which matches the conditions
      # @param kwargs [Hash] conditions to filter the data
      # @return [Relation] the instance of relation
      def where(**kwargs)
      end
    end

    def save!
      save(validate: true)
    end

    def save(validate: false)
      fields.each do |_, field|
        next unless field.unsaved

        field.store_unsaved(validate: validate)
      end
    end

    private

    attr_reader :fields

    # Making a key according to given field in the model
    # @param field [#to_s] the name of the field
    # @return [String] the key on which value is stored
    def field_key(field)
      "lingonberry:#{self.class.name.downcase}:#{field}"
    end
  end
end
