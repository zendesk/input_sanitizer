# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'input_sanitizer/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Zendesk"]
  gem.email         = ["opensource@zendesk.com"]
  gem.description   = %q{Gem to sanitize hash of incoming data}
  gem.summary       = %q{Gem to sanitize hash of incoming data}
  gem.homepage      = ""
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "input_sanitizer"
  gem.require_paths = ["lib"]
  gem.version       = InputSanitizer::VERSION

  gem.add_runtime_dependency "method_struct", ">= 0.2.2"

  if RUBY_VERSION =~ /^1\.8/
    gem.add_runtime_dependency "activesupport", ">= 3.0.0", "< 3.2.0"
    gem.add_development_dependency "pry", "~> 0.9.0"
  else
    gem.add_runtime_dependency "activesupport", ">= 3.0.0"
    gem.add_development_dependency "pry", "~> 0.10.1"
    gem.add_development_dependency "simplecov", "~> 0.9.2"
  end

  gem.add_development_dependency "rspec", "~> 3.2.0"
end
