require_relative "abstract_model"
require_relative "types/abstract_type"

module Lingonberry
  class Schema
    class TempModel
      attr_reader :name
      attr_reader :fields

      def initialize(class_name)
        @name = Helpers::Strings.classify(class_name.to_s)
      end

      class << self
        def define_field_setter(method_name, type)
          define_method(method_name) do |name, **kwargs|
            @fields ||= []
            
            @fields << [name, type, kwargs]
          end
        end
      end
    end

    class << self
      def inherited(klass)
        klass::TempModel.class_eval do
          Helpers.descendants(Types::AbstractType).each do |type|
            method_name = Helpers::Strings.snake_case(type.name.demodulize)
            define_field_setter(method_name, type)
          end
        end
        super(klass)
      end

      def custom_types(*modules)
        modules.each do |m|
          m.constants.each do |constant|
            type = Helpers::Strings.constantize("#{m}::#{constant}")
            next unless Helpers.descendant?(Types::AbstractType, type)

            method_name = Helpers::Strings.snake_case(type.name)

            TempModel.class_eval do
              define_field_setter(method_name, type)
            end
          end
        end
      end

      def call_field(klass, name, type, array: false, **kwargs)
        if type == Types::PrimaryKey
          klass.send(:primary_key, name, **kwargs)
        else
          if array
            type = [type]
          end
          klass.send(:field, name, type, **kwargs)
        end
      end

      # create metaklasses for models if models isn't defined as the class
      # implement for the model fields
      def define
        @models.each do |model|
          klass = if Object.const_defined? model.name
            new_model = Object.const_get(model.name)
            raise Errors::UnknownBaseClass, "#{model}" unless Helpers.descendant? AbstractModel, new_model

            new_model
          else
            new_model = Class.new(AbstractModel)
            Helpers::Strings.constantize_with_set!(model.name, new_model)
            new_model
          end
          model.fields.each do |name, type, kwargs|
            call_field(klass, name, type, **kwargs)
          end
        end
      end

      def model(model_name, &block)
        model = TempModel.new model_name
        yield model
        @models ||= []
        @models << model
      end
    end
  end
end
