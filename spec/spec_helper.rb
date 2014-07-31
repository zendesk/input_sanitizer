require 'bundler'
Bundler.setup(:test)

unless ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :should
  end

  config.mock_with :rspec do |c|
    c.syntax = :should
  end
end

require 'input_sanitizer'
require 'pry'
