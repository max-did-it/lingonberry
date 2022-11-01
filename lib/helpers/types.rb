module Roarm
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

      module DefaultOptions
        class << self
          def extended(klass)
            klass.class_eval do
              class << self
                def inherited(subclass)
                  subclass.instance_variable_set(:@default_options, {})
                  super
                end

                attr_accessor :default_options
              end
            end

            if @methods_to_inherit.include?(:length)
              klass.class_eval do
                attr_reader :length

                class << self
                  def length(gt: -1, lt: -1, gteq: -1, lteq: -1, eq: -1)
                    default_options[:length] = {
                      gt: gt,
                      gteq: gteq,
                      lt: lt,
                      lteq: lteq,
                      eq: eq
                    }
                  end
                end
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
                    default_options[:null] = flag
                  end
                end
              end
            end

            if @methods_to_inherit.include?(:keys)
              klass.class_eval do
                attr_reader :keys

                class << self
                  def keys(*args, **kwargs)
                    default_options[:keys] = if args
                                              args.map!(&:to_sym)
                                            elsif kwargs
                                              kwargs.transform_keys!(&:to_sym)
                                            else
                                              raise Error::NoArgsGiven, "Need pass Array or Hash as arguments for #{self.class}#keys"
                                            end
                  end
                end
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
