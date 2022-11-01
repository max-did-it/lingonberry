module Roarm
  module Types
    # Abstract class for all Roarm Types
    class AbstractType
      extend Helpers::Types::DefaultOptions[:null]
      class << self
        def new(*args, **kwargs)
          raise Errors::AbstractClass if superclass == Object

          super(*args, **kwargs)
        end

        def ===(klass)
          Helpers.descendants(self).include?(klass)
        end
      end

      def initialize(*args, **kwargs)
      ensure
        set_default_options(*args, **kwargs)
      end

      # prepare value for storage
      # @param value [Object] the value which must be serialized
      # @return [String] the result of serialization
      def serialize(value)
        value.to_s
      end

      # prepare value for storage
      # @param value [Object] the value which must be deserialized
      # @return [String] the result of deserialization
      def deserialize(value)
        value
      end

      # makes some checks based on type
      # @param value [Object] the value must be validated
      def validate(value)
        raise Error::AbstractMethodCalled
      end

      # store the value in Redis by the given key
      #   default method used for store value is Redis#set
      #   rewrite this method for your type need another one
      # @param conn [Redis] the connection to the redis
      # @param key [String] the key for store the value
      # @param value [String] the value must be stored
      # @return [true, false] true if result set is successfully and false if something goes wrong
      def set(conn, key, value)
        conn.set(key, serialize(value)) == "OK"
      end

      # get the value from Redis by the given key
      # @param conn [Redis] the connection to the redis
      # @param key [String] the key for store the value
      # @return [String] value coerced to string
      def get(conn, key, *_args, **_kwargs)
        deserialize conn.get(key)
      end

      private

      def set_default_options(*_args, **kwargs)
        self.class.default_options&.each do |option, value|
          instance_variable_set("@#{option}", kwargs[:option] || value)
        end
      end
    end
  end
end
