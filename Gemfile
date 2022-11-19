source "https://rubygems.org"

ruby ">= 2.6.0"
gem "connection_pool", "~> 2.3"
gem "redis"
gem "hiredis-client"
gem "rake"

group :development do
  gem "yard", "~> 0.9.27"
end

group :development, :test do
  gem "byebug"
  gem "pry"
  gem "pry-byebug"
end

group :test do
  gem "mock_redis"
  gem "activesupport", "~> 5.0"
  gem "factory_bot", "~> 6.0"
  gem "rspec", "~> 3.11"
end

gem "redcarpet", "~> 3.5"
