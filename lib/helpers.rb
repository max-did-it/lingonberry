module Lingonberry
  module Helpers
    class << self
      def descendants(base)
        ObjectSpace.each_object(Class).select { |klass| klass < base }
      end

      def descendant?(parent, child)
        descendants(parent).include?(child)
      end
    end
    module Strings
      class << self
        def classify(string)
          namespaces = string.split("__")
          namespaces.map { |ns| ns.split("_").map(&:capitalize).join }.join("::")
        end

        def snake_case(string)
          string.gsub(/(([A-Z]{1}[a-z0-9]+)+)(:{2})?/, '\1__').delete_suffix("__").split("__").map { |m| m.gsub(/(.)([A-Z])/, '\1_\2').downcase }.join("__")
        end

        def constantize(string)
          string.split("::").inject(Object) { |obj, const| obj.const_get(const) }
        end

        def constantize_with_set!(string, metaclass)
          namespaces = string.split("::")
          klass = namespaces[-1]
          namespaces.inject(Object) do |obj, const|
            if const == klass
              obj.const_set(const, metaclass)
            else
              obj.const_set(const, Class.new(Module)) unless obj.const_defined?(const)
            end
            obj.const_get(const)
          end
        end
      end
    end
  end
end
