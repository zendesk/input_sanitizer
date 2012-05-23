# -*- encoding: utf-8 -*-
require File.expand_path('../lib/input_sanitizer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tomek Paczkowski", "Tomasz Werbicki"]
  gem.email         = ["tom@futuresimple.com", "tomasz@futuresimple.com"]
  gem.description   = %q{Gem to sanitize hash of incoming data}
  gem.summary       = %q{Gem to sanitize hash of incoming data}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "input_sanitizer"
  gem.require_paths = ["lib"]
  gem.version       = InputSanitizer::VERSION

  gem.add_development_dependency "rspec"
end
