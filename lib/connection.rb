require "connection_pool"
require "redis"
module Lingonberry
  def self.connection
    CONNECTION_POOL.with do |conn|
      yield conn
    end
  end

  private

  CONNECTION_POOL = ::ConnectionPool.new(size: @config.redis_pool_size, timeout: @config.redis_conn_timeout) { ::Redis.new(url: @config.redis_url) }
end
