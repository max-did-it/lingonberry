module Lingonberry
  class << self
    attr_reader :config
    def configure
      @config = OpenStruct.new
      @config.redis_url = "redis://localhost/0"
      @config.redis_conn_timeout = 4
      @config.redis_pool_size = 100
      @config.safe_mode = false
      @config.driver = :ruby
      yield @config if block_given?
    end
  end
end
