require_relative "abstract_type"

module Lingonberry
  module Types
    class Hash < AbstractType
      # {Helpers::Types::DefaultOptions#extended}
      extend Helpers::Types::DefaultOptions[:keys]

      def initialize(*args, **kwargs)
        super(*args, **kwargs)
        @interface = Interface.new
      end

      def serialize(value)
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

        # rubocop:disable Performance/InefficientHashSearch
        def key_in_type?(key)
          return true unless type.keys

          type.keys.include?(key.to_sym)
        end
        # rubocop:enable Performance/InefficientHashSearch

        attr_reader :storage_key, :type
      end

      def get(_conn, key, *args, **kwargs)
        @interface.chain(self, key)
      end

      def set(conn, key, values, *args, **kwargs)
        conn.del(key)
        @interface.instance_variable_set(:@hash, {})
        conn.hset(key, serialize(values))
      ensure
        post_set(conn, key, values, *args, **kwargs)
      end
    end
  end
end
