module Lingonberry
  module Types
    # Abstract class for all Lingonberry Types
    class AbstractType
      # {Helpers::Types::DefaultOptions#extended}
      extend Helpers::Types::DefaultOptions[
        :null, :serializer,
        :deserializer, :validator,
        :expire
      ]

      null true
      expire(-1)

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
        return deserializer.call(value) if deserializer

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

      def post_set(conn, key, value, *args, **kwargs)
        set_ttl(conn, key) if expire.positive?
      end

      def set_ttl(conn, key)
        conn.expire(key, expire)
      end

      def set_default_options(*_args, **kwargs)
        self.class.extra_options&.each do |option|
          instance_variable_set("@#{option}", kwargs[option] || self.class.default_options[option])
        end
      end
    end
  end
end
