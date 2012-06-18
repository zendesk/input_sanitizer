# InputSanitizer [![Build Status](https://secure.travis-ci.org/futuresimple/input_sanitizer.png?branch=master)](http://travis-ci.org/futuresimple/input_sanitizer)

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
  float :weight
  date :birthday
end

# filters unwanted parameters
sanitizer = UpdatePerson.new({:account_id => 1, :name => "John"})
sanitizer.cleaned() # => {:name => "John"}

# provides key access
sanitizer[:name] # => "John"

# also provides shortcut method, same as new({}).cleaned
UpdatePerson.clean({:account_id => 1})

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
# => ...
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
