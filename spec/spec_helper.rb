require "simplecov"
require "bundler"
SimpleCov.start
Bundler.require

RSpec.configure do |config|
  config.mock_with :mocha
end

