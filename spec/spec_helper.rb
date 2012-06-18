require 'bundler'
Bundler.setup(:test)

require 'simplecov'
SimpleCov.start unless ENV['CI'] == 'true'

require 'input_sanitizer'
