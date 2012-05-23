# InputSanitizer

Gem to sanitize hash of incoming data

## Installation

Add this line to your application's Gemfile:

    gem 'input_sanitizer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install input_sanitizer

## Usage

    class Person
      validates_numericality_of :height, :greater_than => 0
    end

    class PersonSanitizer < Sanitizer
      string :name
      string :address
      integer :height
      float :weight
      date :birthday
      sub :contact_info, ContactSanitizer
    end

    class PrivilegedSanitizer < PersonSanitizer
      integer :account_id
    end

    class ZzzConverter < Converter
      def to_ruby(value)
        value.to_s.gsub('zzz', '')
      end
    end


    class Point3d < Sanitizer
      type :mytype, ZzzConverter

      float :x, :y, :z
      mytype :zzz
    end


    # filters unwanted parameters
    sanitizer = UpdatePerson.new({:account_id => 1})
    sanitizer.to_hash() # => {}

    # also available as shortcut
    UpdatePerson.to_hash({:account_id => 1}) # => {}

    # supports inheritance
    PrivilegedSanitizer.to_hash({:account_id => 1}) # => {:account_id => 1}

    # has compatible flow
    sanitizer = UpdatePerson.new({:account_id => 1, :height => -1})
    if sanitizer.update_model(person)
        redirect
    else
        render :json => sanitizer.errors.to_json
    end

    # gathers errors from active record
    sanitizer.error # => {:height => "must be > 0"}



    # handles type conversions
    PrivilegedSanitizer.to_hash({:account_id => '1'}) # => {:account_id => 1}
    PrivilegedSanitizer.to_hash({:birthday => '1986-10-06'}) # => {:birthday => Date.new(1986, 10, 6)}




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
