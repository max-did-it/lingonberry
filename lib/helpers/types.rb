module Lingonberry
  module Helpers
    module Types
      # Helper to make a construction like Enum[] which creates a Array type with elements type Enum
      module ArrayOf
        class << self
          # When incldued in type allow to use construction Type[] to declare field with type array of Types
          def []
            Types::Array[self]
          end
        end
      end

      module Options
        class << self
          def extended(klass)
            klass.class_eval do
              class << self
                attr_reader :extra_options, :default_options

                def inherited(subclass)
                  subclass.instance_variable_set(:@default_options, @default_options.dup)
                  subclass.instance_variable_set(:@extra_options, @extra_options.dup)
                  super
                end
              end
            end

            existing_default_options = klass.instance_variable_get(:@default_options) || {}
            klass.instance_variable_set(:@default_options, existing_default_options)
            existing_extra_options = klass.instance_variable_get(:@extra_options) || []
            klass.instance_variable_set(:@extra_options, (existing_extra_options + @methods_to_inherit).uniq)

            if @methods_to_inherit.include?(:serializer)
              klass.class_eval do
                attr_reader :serializer

                class << self
                  def serializer(&block)
                    raise Errors::InvalidValue unless block

                    @default_options[:serializer] = block
                  end
                end
              end
            end

            if @methods_to_inherit.include?(:deserializer)
              klass.class_eval do
                attr_reader :deserializer

                class << self
                  def deserializer(&block)
                    raise Errors::InvalidValue unless block

                    @default_options[:deserializer] = block
                  end
                end
              end
            end

            if @methods_to_inherit.include?(:validator)
              klass.class_eval do
                attr_reader :validator

                class << self
                  def validator(&block)
                    raise Errors::InvalidValue unless block

                    @default_options[:validator] = block
                  end
                end
              end
            end

            if @methods_to_inherit.include?(:length)
              klass.class_eval do
                attr_reader :length

                class << self
                  def length(gt: -1, lt: -1, gteq: -1, lteq: -1, eq: -1)
                    @default_options[:length] = {
                      gt: gt,
                      gteq: gteq,
                      lt: lt,
                      lteq: lteq,
                      eq: eq
                    }
                  end
                end
                length(gt: -1, lt: -1, gteq: -1, lteq: -1, eq: -1)
              end
            end

            if @methods_to_inherit.include?(:uniq)
              klass.class_eval do
              end
            end

            if @methods_to_inherit.include?(:null)
              klass.class_eval do
                attr_reader :null

                class << self
                  def null(flag = true)
                    @default_options[:null] = flag
                  end
                end

                null true
              end
            end

            if @methods_to_inherit.include?(:expire)
              klass.class_eval do
                attr_reader :expire

                class << self
                  def expire(ttl = -1)
                    raise Errors::InvalidValue unless ttl.is_a?(::Integer)

                    @default_options[:expire] = ttl
                  end
                end

                expire(-1)
              end
            end

            if @methods_to_inherit.include?(:keys)
              klass.class_eval do
                attr_reader :keys

                class << self
                  def keys(values)
                    @default_options[:keys] = case values
                    when Array
                      values.map(&:to_sym)
                    when Hash
                      values.transform_keys(&:to_sym)
                    else
                      raise Error::NoArgsGiven, "Need pass ::Array or ::Hash as arguments for #{self.class}#keys"
                    end
                  end
                end
                keys []
              end
            end
            @methods_to_inherit = nil
          end

          def [](*args)
            @methods_to_inherit = args.map!(&:to_sym)
            self
          end
        end
      end
    end
  end
end
