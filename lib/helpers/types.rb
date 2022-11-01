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
            if @methods_to_inherit.include?(:uniq)
              klass.class_eval do
                def self.uniq(flag = false)
                  @uniq = flag
                end
              end
            end

            if @methods_to_inherit.include?(:null)
              klass.class_eval do
                def self.null(flag = true)
                  @null = flag
                end
              end
            end

            if @methods_to_inherit.include?(:keys)
              klass.class_eval do
                def self.keys(*args, **kwargs)
                  if args
                    @keys = args.map!(&:to_sym)
                  elsif kwargs
                    @keys = kwargs.transform_keys!(&:to_sym)
                  else
                    raise Error::NoArgsGiven, "Need pass Array or Hash as arguments for #{self.class}#keys"
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
