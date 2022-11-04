require_relative "abstract_type"

module Lingonberry
  module Types
    class PrimaryKey < Set
      def initialize(*args, **kwargs)
        kwargs[:sorted] = true
        super(*args, **kwargs)
      end

      def serialize(_values)
        generate_id
      end

      private

      def generate_id
        Time.now.to_f
      end
    end
  end
end
