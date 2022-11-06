require_relative "abstract_type"

module Lingonberry
  module Types
    class Hash < AbstractType
      # {Helpers::Types::Options#extended}
      extend Helpers::Types::Options[:keys]

      def initialize(*args, **kwargs)
        super(*args, **kwargs)
        @interface = Interface.new
      end

      def serialize(value)
        return serializer.call(value) if serializer

        case value
        when ::Hash
          unknown_keys = []
          unknown_keys = (value.keys - keys) if !keys.nil? && keys.any?

          raise Errors::UnknownKey, "#{unknown_keys} must be in #{keys}" if unknown_keys.any?

          value.transform_values!(&:to_s)
        else
          value.to_s
        end
      end

      def deserialize(value)
        return patch_future_object(value) if value.is_a?(Redis::Future)
        return deserializer.call(value) if deserializer

        value
      end

      class Interface
        attr_reader :hash

        def initialize
          @hash = {}
        end

        def chain(type, storage_key)
          @storage_key = storage_key
          @type = type
          self
        end

        def [](key)
          raise Errors::UnknownKey unless key_in_type?(key)

          Lingonberry.connection do |conn|
            @hash[key.to_sym] = type.deserialize conn.hget(storage_key, key)
          end
          @hash[key.to_sym]
        end

        # rubocop:disable Lint/Void
        def []=(key, value)
          raise Errors::UnknownKey unless key_in_type?(key)

          Lingonberry.connection do |conn|
            hash[key] = type.serialize conn.hset(storage_key, key, type.serialize(value))
          end
          self
        end
        # rubocop:enable Lint/Void

        def to_h
          Lingonberry.connection do |conn|
            @hash = conn.hgetall(storage_key)&.transform_keys!(&:to_sym)
          end
          @hash
        end

        private

        # rubocop:disable Lint/RedundantCopDisableDirective
        # rubocop:disable Performance/InefficientHashSearch
        def key_in_type?(key)
          return true unless type.keys

          type.keys.include?(key.to_sym)
        end
        # rubocop:enable Performance/InefficientHashSearch
        # rubocop:enable Lint/RedundantCopDisableDirective

        attr_reader :storage_key, :type
      end

      def get(key, values, *args, **kwargs)
        @interface.chain(self, key)
      end

      def set(key, values, *args, **kwargs)
        if connection.is_a? Redis::MultiConnection
          store_block(connection, key, values, *args, **kwargs)
        else
          connection.multi do |conn|
            store_block(conn, key, values, *args, **kwargs)
          end
        end
      end

      private

      def store_block(conn, key, values, *args, **kwargs)
        conn.del(key)
        @interface.instance_variable_set(:@hash, {})

        values_to_insert = serialize(values)
        conn.hset(key, values_to_insert) == values_to_insert.count
      end
    end
  end
end
