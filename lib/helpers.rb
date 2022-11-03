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
  end
end
