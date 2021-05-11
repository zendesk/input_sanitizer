require 'spec_helper'

class AddressSanitizer < InputSanitizer::V2::PayloadSanitizer
  string :city
  string :zip
end

class TagSanitizer < InputSanitizer::V2::PayloadSanitizer
  integer :id
  string :name
  nested :addresses, :sanitizer => AddressSanitizer, :collection => true
end

class TestedPayloadSanitizer < InputSanitizer::V2::PayloadSanitizer
  integer :array, :collection => true
  integer :array_nil, :collection => true, :allow_nil => true
  string :status, :allow => ['current', 'past']
  string :status_with_empty, :allow => ['', 'current', 'past']
  string :regexp_string, :regexp => /^#?([a-f0-9]{6}|[a-f0-9]{3})$/
  string :utf8mb4_string, :strip_4byte_chars => true
  nested :address, :sanitizer => AddressSanitizer
  nested :nullable_address, :sanitizer => AddressSanitizer, :allow_nil => true
  nested :tags, :sanitizer => TagSanitizer, :collection => true

  float :float_attribute, :minimum => 1, :maximum => 100
  integer :integer_attribute, :minimum => 1, :maximum => 100
  string :string_attribute
  boolean :bool_attribute
  datetime :datetime_attribute
  date :date_attribute, :minimum => Date.new(-2015, 01, 01), :maximum => Date.new(2015, 12, 31)

  url :website
  string :limited_collection, :collection => { :minimum => 1, :maximum => 2 }, :minimum => 2, :maximum => 12
  string :allow_collection, :collection => true, :allow => ['yes', 'no']
end

class BlankValuesPayloadSanitizer < InputSanitizer::V2::PayloadSanitizer
  string :required_string, :required => true
  datetime :non_nil_datetime, :allow_nil => false
  url :non_blank_url, :allow_blank => false
end

class CustomConverterWithProvidedValue < InputSanitizer::V2::PayloadSanitizer
  integer :from
  custom :to, :provide => :from, :converter => lambda { |value, options|
    InputSanitizer::V2::Types::IntegerCheck.new.call(value)
    raise InputSanitizer::ValueError.new(value, options[:provided][:from], nil) if options[:provided][:from] > value
    value
  }
end

describe InputSanitizer::V2::PayloadSanitizer do
  let(:sanitizer) { TestedPayloadSanitizer.new(@params) }
  let(:cleaned) { sanitizer.cleaned }

  describe "collections" do
    it "is invalid if collection is not an array" do
      @params = { :array => {} }
      sanitizer.should_not be_valid
    end

    it "is valid if collection is an array" do
      @params = { :array => [] }
      sanitizer.should be_valid
    end

    it "is valid if collection is an nil and allow_nil is passed" do
      @params = { :array_nil => nil }
      sanitizer.should be_valid
    end

    it "is invalid if there are too few elements" do
      @params = { :limited_collection => [] }
      sanitizer.should_not be_valid
    end

    it "is invalid if there are too many elements" do
      @params = { :limited_collection => ['bear', 'bear', 'bear'] }
      sanitizer.should_not be_valid
    end

    it "is valid when there are just enough elements" do
      @params = { :limited_collection => ['goldilocks'] }
      sanitizer.should be_valid
    end

    it "is invalid when any of the elements are too long" do
      @params = { :limited_collection => ['more_than_the_limit'] }
      sanitizer.should_not be_valid
    end

    it "is invalid when any of the elements are too short" do
      @params = { :limited_collection => ['a'] }
      sanitizer.should_not be_valid
    end

    it "is invalid when given disallowed value in a collection" do
      @params = { :allow_collection => ['yes', 'no', 'whoa'] }
      sanitizer.should_not be_valid
    end

    it "is valid when given allowed values in a collection" do
      @params = { :allow_collection => ['yes', 'no'] }
      sanitizer.should be_valid
    end
  end

  describe "allow option" do
    it "is valid when given an allowed string" do
      @params = { :status => 'past' }
      sanitizer.should be_valid
    end

    it "is invalid when given an empty string" do
      @params = { :status => '' }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('/status')
    end

    it "is valid when given an allowed empty string" do
      @params = { :status_with_empty => '' }
      sanitizer.should be_valid
    end

    it "is invalid when given a disallowed string" do
      @params = { :status => 'current bad string' }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('/status')
    end
  end

  describe "minimum and maximum options" do
    it "is invalid if integer is lower than the minimum" do
      @params = { :integer_attribute => 0 }
      sanitizer.should_not be_valid
    end

    it "is invalid if integer is greater than the maximum" do
      @params = { :integer_attribute => 101 }
      sanitizer.should_not be_valid
    end

    it "is valid when integer is within given range" do
      @params = { :limited_collection => ['goldilocks'] }
      sanitizer.should be_valid
    end

    it "is invalid if float is lower than the minimum" do
      @params = { :float_attribute => 0.0 }
      sanitizer.should_not be_valid
    end

    it "is invalid if float is greater than the maximum" do
      @params = { :float_attribute => 101.0 }
      sanitizer.should_not be_valid
    end
  end

  describe "strip_4byte_chars option" do
    it "is valid when given a string with 4-byte chars" do
      @params = { :utf8mb4_string => " some \u{1F435} value " }
      sanitizer.should be_valid
    end

    it "returns sanitized string without 4-byte chars" do
      @params = { :utf8mb4_string => " some \u{1F435} value " }
      sanitizer[:utf8mb4_string].should eq " some   value "
    end
  end

  describe "strict param checking" do
    it "is invalid when given extra params" do
      @params = { :extra => 'test', :extra2 => 1 }
      sanitizer.should_not be_valid
      sanitizer.errors.count.should eq(2)
    end

    it "is invalid when given extra params in a nested sanitizer" do
      @params = { :address => { :extra => 0 }, :tags => [ { :extra2 => 1 } ] }
      sanitizer.should_not be_valid
      sanitizer.errors.map(&:field).should contain_exactly('/address/extra', '/tags/0/extra2')
    end
  end

  describe "converters with provided values" do
    let(:sanitizer) { CustomConverterWithProvidedValue.new(@params) }

    it "is valid when converter passes check with provided value" do
      @params = {from: 1, to: 3}
      sanitizer.should be_valid
    end

    it "is invalid when converter does not pass check with provided value" do
      @params = {from: 3, to: 1}
      sanitizer.should_not be_valid
    end
  end

  describe "strict type checking" do
    it "is invalid when given string instead of integer" do
      @params = { :integer_attribute => '1' }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('/integer_attribute')
    end

    it "is valid when given an integer" do
      @params = { :integer_attribute => 50 }
      sanitizer.should be_valid
      sanitizer[:integer_attribute].should eq(50)
    end

    it "is invalid when given a float" do
      @params = { :integer_attribute => 50.99 }
      sanitizer.should_not be_valid
    end

    it "is valid when given nil for an integer" do
      @params = { :integer_attribute => nil }
      sanitizer.should be_valid
      sanitizer[:integer_attribute].should be_nil
    end

    it "is invalid when given string instead of float" do
      @params = { :float_attribute => '1' }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('/float_attribute')
    end

    it "is valid when given a float" do
      @params = { :float_attribute => 50.0 }
      sanitizer.should be_valid
      sanitizer[:float_attribute].should eq(50.0)
    end

    it "is valid when given nil for a float" do
      @params = { :float_attribute => nil }
      sanitizer.should be_valid
      sanitizer[:float_attribute].should be_nil
    end

    it "is valid when given string is matching regexp" do
      @params = { :regexp_string => "#8bd635" }
      sanitizer.should be_valid
      sanitizer[:regexp_string].should eq('#8bd635')
    end

    it "is invalid when given string is not matching regexp" do
      @params = { :regexp_string => "not a hex value" }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('/regexp_string')
    end

    it "is invalid when given integer instead of string" do
      @params = { :string_attribute => 0 }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('/string_attribute')
    end

    it "is invalid when given float instead of string" do
      @params = { :string_attribute => 3.1415 }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('/string_attribute')
    end

    it "is valid when given a string" do
      @params = { :string_attribute => '#@!#%#$@#ad' }
      sanitizer.should be_valid
      sanitizer[:string_attribute].should eq('#@!#%#$@#ad')
    end

    it "is invalid when given 'yes' as a bool" do
      @params = { :bool_attribute => 'yes' }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('/bool_attribute')
    end

    it "is valid when given true as a bool" do
      @params = { :bool_attribute => true }
      sanitizer.should be_valid
    end

    it "is valid when given false as a bool" do
      @params = { :bool_attribute => false }
      sanitizer.should be_valid
    end

    it "is invalid when given an incorrect datetime" do
      @params = { :datetime_attribute => "2014-08-2716:32:56Z" }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('/datetime_attribute')
    end

    it "is valid when given a correct datetime" do
      @params = { :datetime_attribute => "2014-08-27T16:32:56Z" }
      sanitizer.should be_valid
    end

    it "is valid when given a 'forever' timestamp" do
      @params = { :datetime_attribute => "9999-12-31T00:00:00Z" }
      sanitizer.should be_valid
    end

    it "is invalid when given an incorrect date" do
      @params = { :date_attribute => "invalid" }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('/date_attribute')
    end

    it "is valid when given a correct date" do
      @params = { :date_attribute => "2015-08-27" }
      sanitizer.should be_valid
    end

    it "is valid when given a correct negative date" do
      @params = { :date_attribute => "-2014-08-27" }
      sanitizer.should be_valid
    end

    it "is valid when given a correct URL" do
      @params = { :website => "https://google.com" }
      sanitizer.should be_valid
      sanitizer[:website].should eq("https://google.com")
    end

    it "is invalid when given an invalid URL" do
      @params = { :website => "ht:/google.com" }
      sanitizer.should_not be_valid
    end

    it "is invalid when given an invalid URL that contains a valid URL" do
      @params = { :website => "watwat http://google.com wat" }
      sanitizer.should_not be_valid
    end

    describe "blank and required values" do
      let(:sanitizer) { BlankValuesPayloadSanitizer.new(@params) }
      let(:defaults) { { :required_string => 'zz' } }

      it "is invalid if required string is missing" do
        @params = {}
        sanitizer.should_not be_valid
        sanitizer.errors[0].should be_an_instance_of(InputSanitizer::ValueMissingError)
        sanitizer.errors[0].field.should eq('/required_string')
      end

      it "is invalid if required string is nil" do
        @params = { :required_string => nil }
        sanitizer.should_not be_valid
        sanitizer.errors[0].should be_an_instance_of(InputSanitizer::BlankValueError)
        sanitizer.errors[0].field.should eq('/required_string')
      end

      it "is invalid if required string is blank" do
        @params = { :required_string => ' ' }
        sanitizer.should_not be_valid
        sanitizer.errors[0].should be_an_instance_of(InputSanitizer::BlankValueError)
        sanitizer.errors[0].field.should eq('/required_string')
      end

      it "is invalid if non-nil datetime is null" do
        @params = defaults.merge({ :non_nil_datetime => nil })
        sanitizer.should_not be_valid
        sanitizer.errors[0].should be_an_instance_of(InputSanitizer::BlankValueError)
        sanitizer.errors[0].field.should eq('/non_nil_datetime')
      end

      it "is valid if non-nil datetime is blank" do
        @params = defaults.merge({ :non_nil_datetime => '' })
        sanitizer.should be_valid
      end

      it "is invalid if non-blank url is nil" do
        @params = defaults.merge({ :non_blank_url => nil })
        sanitizer.should_not be_valid
        sanitizer.errors[0].should be_an_instance_of(InputSanitizer::BlankValueError)
        sanitizer.errors[0].field.should eq('/non_blank_url')
      end

      it "is invalid if non-blank url is blank" do
        @params = defaults.merge({ :non_blank_url => '' })
        sanitizer.should_not be_valid
        sanitizer.errors[0].should be_an_instance_of(InputSanitizer::BlankValueError)
        sanitizer.errors[0].field.should eq('/non_blank_url')
      end
    end

    describe "nested checking" do
      describe "simple array" do
        it "returns JSON pointer for invalid fields" do
          @params = { :array => [1, 'z', '3', 4] }
          sanitizer.errors.length.should eq(2)
          sanitizer.errors.map(&:field).should contain_exactly('/array/1', '/array/2')
        end
      end

      describe "nested object" do
        it "returns an error when given a nil for a nested value" do
          @params = { :address => nil }
          sanitizer.should_not be_valid
        end

        it "returns an error when given a string for a nested value" do
          @params = { :address => 'nope' }
          sanitizer.should_not be_valid
        end

        it "returns an error when given an array for a nested value" do
          @params = { :address => ['a'] }
          sanitizer.should_not be_valid
        end

        it "returns JSON pointer for invalid fields" do
          @params = { :address => { :city => 0, :zip => 1 } }
          sanitizer.errors.length.should eq(2)
          sanitizer.errors.map(&:field).should contain_exactly('/address/city', '/address/zip')
        end

        it "allows nil with `allow_nil` flag" do
          @params = { :nullable_address => nil }
          sanitizer.should be_valid
          sanitizer.cleaned.fetch(:nullable_address).should eq(nil)
        end
      end

      describe "array of nested objects" do
        it "returns an error when given a nil for a collection" do
          @params = { :tags => nil }
          sanitizer.should_not be_valid
        end

        it "returns an error when given a string for a collection" do
          @params = { :tags => 'nope' }
          sanitizer.should_not be_valid
        end

        it "returns an error when given a hash for a collection" do
          @params = { :tags => { :a => 1 } }
          sanitizer.should_not be_valid
        end

        it "returns JSON pointer for invalid fields" do
          @params = { :tags => [ { :id => 'n', :name => 1 }, { :id => 10, :name => 2 } ] }
          sanitizer.errors.length.should eq(3)
          sanitizer.errors.map(&:field).should contain_exactly(
            '/tags/0/id',
            '/tags/0/name',
            '/tags/1/name'
          )
        end
      end

      describe "array of nested objects that have array of nested objects" do
        it "returns JSON pointer for invalid fields" do
          @params = { :tags => [
            { :id => 'n', :addresses => [ { :city => 0 }, { :city => 1 } ] },
            { :name => 2, :addresses => [ { :city => 3 } ] },
          ] }
          sanitizer.errors.length.should eq(5)
          sanitizer.errors.map(&:field).should contain_exactly(
            '/tags/0/id',
            '/tags/0/addresses/0/city',
            '/tags/0/addresses/1/city',
            '/tags/1/name',
            '/tags/1/addresses/0/city'
          )

          ec = sanitizer.error_collection
          ec.length.should eq(5)
        end
      end
    end
  end
end
