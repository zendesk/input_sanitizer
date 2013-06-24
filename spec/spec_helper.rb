require 'bundler'
Bundler.setup(:test)

unless ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

require 'input_sanitizer'
