module Lingonberry
  module Types
    # Abstract class for all Lingonberry Types
    class AbstractType
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[
        :null, :serializer,
        :deserializer, :validator,
        :expire,
        :generator
      ]

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
        @context = kwargs[:context]
      ensure
        set_default_options(*args, **kwargs)
      end

      # prepare value for storage
      # @param value [Object] the value which must be serialized
      # @return [String] the result of serialization
      def serialize(value)
        return serializer.call(value) if serializer

        value.to_s
      end

      # prepare value for storage
      # @param value [Object] the value which must be deserialized
      # @return [String] the result of deserialization
      def deserialize(value)
        return patch_future_object(value) if value.is_a?(Redis::Future)
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
      def set(key, value, *_args, **_kwargs)
        connection.set(key, serialize(value)) == "OK"
      end

      # get the value from Redis by the given key
      # @param conn [Redis] the connection to the redis
      # @param key [String] the key for store the value
      # @return [String] value coerced to string
      def get(key, *_args, **_kwargs)
        deserialize connection.get(key)
      end

      def post_set(key, value, *args, **kwargs)
        set_ttl(key) if expire.positive?
      end

      private

      def set_ttl(key)
        connection.expire(key, expire)
      end

      def set_default_options(*_args, **kwargs)
        extra = self.class.instance_variable_get(:@extra_options)
        default = self.class.instance_variable_get(:@default_options)
        extra&.each do |option|
          instance_variable_set("@#{option}", kwargs[option] || default[option])
        end
      end

      def patch_future_object(future_object)
        deserialize_func = method(:deserialize)
        future_object.instance_exec(deserialize_func) { |func| @coerce = func }
        future_object
      end

      def connection
        @context.transaction || @context.connection
      end
    end
  end
end
