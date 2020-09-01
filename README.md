# InputSanitizer
![CI](https://github.com/zendesk/input_sanitizer/workflows/CI/badge.svg)

Gem to sanitize hash of incoming data

## Installation

Add this line to your application's Gemfile:

    gem 'input_sanitizer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install input_sanitizer

## Usage

```ruby
class PersonSanitizer < InputSanitizer::Sanitizer
  string :name
  string :address
  integer :height
  float :ratio
  date :birthday
end

# filters unwanted parameters
sanitizer = PersonSanitizer.new({:account_id => 1, :name => "John"})
sanitizer.cleaned() # => {:name => "John"}

# provides key access
sanitizer[:name] # => "John"

# also provides shortcut method, same as new({}).cleaned
PersonSanitizer.clean({:account_id => 1})

# supports inheritance
class PrivilegedSanitizer < PersonSanitizer
  integer :account_id
end

PrivilegedSanitizer.clean({:account_id => 1})
# => {:account_id => 1}

# handles type conversions
PrivilegedSanitizer.clean({:account_id => '1'})
# => {:account_id => 1}

PrivilegedSanitizer.clean({:birthday => '1986-10-06'})
# => {:birthday => Date.new(1986, 10, 6)}

# it prevents obvious errors
data = PrivilegedSanitizer.clean({:account_id => 3})
data[:account] # instead of :account_id
# => InputSanitizer::KeyNotAllowedError: Key not allowed: account

# supports custom value converters
class SomethingSanitizer < InputSanitizer::Sanitizer
  custom :backward, :converter => lambda { |v| v.reverse }
  integer :version
  custom :name, :provide => :version, :converter => lambda { |name, version|
    version < 3 ? name.downcase : name
  }
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Releasing new version of gem

1. Update version [lib/input_sanitizer/version.rb](lib/input_sanitizer/version.rb) and push to `master`
2. Create new GitHub release with tag name starting with `v` and the version, for example `v0.3.0`
3. Gem will be automatically built and pushed to rubygems.org with GitHub Action

## Copyright and license

Copyright 2012 Zendesk

Licensed under the [Apache License, Version 2.0](LICENSE)
