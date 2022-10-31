module Roarm
  class AbstractModel
    # Can't be initialized by itself, must been inherited
    # @return [Class<Roarm::AbstractModel>] the instance of descendant class
    def initialize
      @fields = self.class.fields.to_h.with_indifferent_access
    end

    class << self
      attr_accessor :fields, :associations

      def new
        raise Errors::AbstractClass if superclass == Object

        super
      end

      # Preload class instance variables for descendants when model inherited from Roarm::AbstractModel or from any descendants
      # @param subclass [Roarm::AbstractModel]
      def inherited(subclass)
        subclass.instance_variable_set(:@fields, [])
        subclass.instance_variable_set(:@sub_fields, [])
        subclass.instance_variable_set(:@enums, [])
        subclass.instance_variable_set(:@relations, [])
        subclass.instance_variable_set(:@pk, nil)
        super
      end

      # Defines a meta read/write accessors by the name of field
      #   for instances
      # @param args [Array] array of arguments.
      #   For available arguments look in Roarm::Field documentations.
      # @param kwargs [Hash] array of kwargs
      #   For available options look in Roarm::Field documentations.
      # @return [nil]
      def field(*args, **kwargs)
        field_name, field_instance = Field.new(*args, **kwargs)
        field_instance.set_key field_key(field_instance.name)

        @fields.push([field_name.to_sym, field_instance]) if field_instance.valid?

        define_method(field_name) do
          fields[__method__].fetch field_key(__method__)
        end

        define_method("#{field_name}=") do |*jargs, **jkwargs|
          field_name = __method__.to_s.delete("=")
          fields[field_name].set(field_key(field_name), *jargs, **jkwargs)
        end

        nil
      end

      # Making a key according to given field in the model
      # @param field [#to_s] the name of the field
      # @return [String] the key on which value is stored
      def field_key(field)
        "roarm:#{self.class.name.demodulize.downcase}:#{field}"
      end
      # end class << self
    end
  end
end
