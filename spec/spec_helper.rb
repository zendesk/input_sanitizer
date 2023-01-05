require 'bundler'
Bundler.setup(:test)

skip_coverage = ENV['CI']

unless skip_coverage
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
