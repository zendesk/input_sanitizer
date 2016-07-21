require 'spec_helper'

# OPTIONS
# :allow_nil (default true)
# :allow_blank (default true)
# :require (default false, requires given key in params, and additionally sets :allow_nil and :allow_blank to false)

#           | allow_nil | allow_blank
# __________|___________|_____________
# string    |    YES    |     YES
# url       |    YES    |     YES
# datetime  |    YES    |     YES
# integer   |    YES    |     NO
# boolean   |    NO     |     NO
# ------------------------------------

# [type, value, option] => valid? # if valid? == false then check for ValueMissing error

test_cases = {
  [InputSanitizer::V2::Types::StringCheck, { :allow_nil => false }, nil] => false,
  [InputSanitizer::V2::Types::StringCheck, { :allow_nil => false }, ""] => true,
  [InputSanitizer::V2::Types::StringCheck, { :allow_nil => false }, "zz"] => true,
  [InputSanitizer::V2::Types::StringCheck, { :allow_blank => false }, nil] => false,
  [InputSanitizer::V2::Types::StringCheck, { :allow_blank => false }, ""] => false,
  [InputSanitizer::V2::Types::StringCheck, { :allow_blank => false }, "zz"] => true,
  [InputSanitizer::V2::Types::StringCheck, { :required => true }, nil] => false,
  [InputSanitizer::V2::Types::StringCheck, { :required => true }, ""] => false,
  [InputSanitizer::V2::Types::StringCheck, { :required => true }, "zz"] => true,
  [InputSanitizer::V2::Types::StringCheck, { }, nil] => true,
  [InputSanitizer::V2::Types::StringCheck, { }, ""] => true,
  [InputSanitizer::V2::Types::StringCheck, { }, "zz"] => true,
  [InputSanitizer::V2::Types::IntegerCheck, { :allow_nil => false }, nil] => false,
  [InputSanitizer::V2::Types::IntegerCheck, { :allow_nil => false }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::IntegerCheck, { :allow_nil => false }, 1] => true,
  [InputSanitizer::V2::Types::IntegerCheck, { :allow_blank => false }, nil] => false,
  [InputSanitizer::V2::Types::IntegerCheck, { :allow_blank => false }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::IntegerCheck, { :allow_blank => false }, 1] => true,
  [InputSanitizer::V2::Types::IntegerCheck, { :required => true }, nil] => false,
  [InputSanitizer::V2::Types::IntegerCheck, { :required => true }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::IntegerCheck, { :required => true }, 1] => true,
  [InputSanitizer::V2::Types::IntegerCheck, { }, nil] => true,
  [InputSanitizer::V2::Types::IntegerCheck, { }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::IntegerCheck, { }, 1] => true,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :allow_nil => false }, nil] => false,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :allow_nil => false }, "null"] => false,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :allow_nil => false }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :allow_nil => false }, []] => :invalid_type,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :allow_nil => false }, 1] => true,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :allow_blank => false }, nil] => false,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :allow_blank => false }, "null"] => false,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :allow_blank => false }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :allow_blank => false }, []] => :invalid_type,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :allow_blank => false }, 1] => true,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :required => true }, nil] => false,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :required => true }, "null"] => false,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :required => true }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :required => true }, []] => :invalid_type,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { :required => true }, 1] => true,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { }, nil] => true,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { }, "null"] => true,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { }, []] => :invalid_type,
  [InputSanitizer::V2::Types::CoercingIntegerCheck, { }, 1] => true,
  [InputSanitizer::V2::Types::BooleanCheck, { :allow_nil => false }, nil] => false,
  [InputSanitizer::V2::Types::BooleanCheck, { :allow_nil => false }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::BooleanCheck, { :allow_nil => false }, true] => true,
  [InputSanitizer::V2::Types::BooleanCheck, { :allow_blank => false }, nil] => false,
  [InputSanitizer::V2::Types::BooleanCheck, { :allow_blank => false }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::BooleanCheck, { :allow_blank => false }, true] => true,
  [InputSanitizer::V2::Types::BooleanCheck, { :required => true }, nil] => false,
  [InputSanitizer::V2::Types::BooleanCheck, { :required => true }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::BooleanCheck, { :required => true }, true] => true,
  [InputSanitizer::V2::Types::BooleanCheck, { }, nil] => false,
  [InputSanitizer::V2::Types::BooleanCheck, { }, ""] => :invalid_type,
  [InputSanitizer::V2::Types::BooleanCheck, { }, true] => true,
  [InputSanitizer::V2::Types::DatetimeCheck, { :allow_nil => false }, nil] => false,
  [InputSanitizer::V2::Types::DatetimeCheck, { :allow_nil => false }, ""] => true,
  [InputSanitizer::V2::Types::DatetimeCheck, { :allow_nil => false }, "2014-08-27T16:32:56Z"] => true,
  [InputSanitizer::V2::Types::DatetimeCheck, { :allow_blank => false }, nil] => false,
  [InputSanitizer::V2::Types::DatetimeCheck, { :allow_blank => false }, ""] => false,
  [InputSanitizer::V2::Types::DatetimeCheck, { :allow_blank => false }, "2014-08-27T16:32:56Z"] => true,
  [InputSanitizer::V2::Types::DatetimeCheck, { :required => true }, nil] => false,
  [InputSanitizer::V2::Types::DatetimeCheck, { :required => true }, ""] => false,
  [InputSanitizer::V2::Types::DatetimeCheck, { :required => true }, "2014-08-27T16:32:56Z"] => true,
  [InputSanitizer::V2::Types::DatetimeCheck, { }, nil] => true,
  [InputSanitizer::V2::Types::DatetimeCheck, { }, ""] => true,
  [InputSanitizer::V2::Types::DatetimeCheck, { }, "2014-08-27T16:32:56Z"] => true,
  [InputSanitizer::V2::Types::DatetimeCheck, { }, 1234] => :invalid_type,
  [InputSanitizer::V2::Types::DatetimeCheck, { }, []] => :invalid_type,
  [InputSanitizer::V2::Types::DatetimeCheck, { }, {}] => :invalid_type,
  [InputSanitizer::V2::Types::URLCheck, { :allow_nil => false }, nil] => false,
  [InputSanitizer::V2::Types::URLCheck, { :allow_nil => false }, ""] => true,
  [InputSanitizer::V2::Types::URLCheck, { :allow_nil => false }, "http://getbase.com"] => true,
  [InputSanitizer::V2::Types::URLCheck, { :allow_blank => false }, nil] => false,
  [InputSanitizer::V2::Types::URLCheck, { :allow_blank => false }, ""] => false,
  [InputSanitizer::V2::Types::URLCheck, { :allow_blank => false }, "http://getbase.com"] => true,
  [InputSanitizer::V2::Types::URLCheck, { :required => true }, nil] => false,
  [InputSanitizer::V2::Types::URLCheck, { :required => true }, ""] => false,
  [InputSanitizer::V2::Types::URLCheck, { :required => true }, "http://getbase.com"] => true,
  [InputSanitizer::V2::Types::URLCheck, { }, nil] => true,
  [InputSanitizer::V2::Types::URLCheck, { }, ""] => true,
  [InputSanitizer::V2::Types::URLCheck, { }, "http://getbase.com"] => true,
}

describe 'type checks' do
  test_cases.each do |(test_case, result)|
    describe test_case[0] do
      context "with options: #{test_case[1]}" do
        show_value = case test_case[2]
        when nil then 'nil'
        when '' then "''"
        else "'#{test_case[2]}'"
        end

        it "correctly handles value #{show_value}" do
          case result
          when true
            lambda { test_case[0].new.call(test_case[2], test_case[1]) }.should_not raise_error
          when false
            lambda { test_case[0].new.call(test_case[2], test_case[1]) }.should raise_error(InputSanitizer::BlankValueError)
          when :invalid_type
            lambda { test_case[0].new.call(test_case[2], test_case[1]) }.should raise_error(InputSanitizer::TypeMismatchError)
          end
        end
      end
    end
  end
end

# Generating test cases:

# types = ['string', 'integer', 'boolean', 'datetime', 'url']
# options = [:allow_nil_false, :allow_blank_false, :required_true, :no_params]
# values = [nil, '', lambda { |type| { 'string' => 'zz', 'integer' => 1, 'boolean' => true, 'datetime' => '2014-08-27T16:32:56Z', 'url' => 'http://getbase.com' }[type] }]
# test_cases = types.product(options).product(values).map(&:flatten).map! do |test_case|
#   test_case[2] = test_case[2].call(test_case[0]) if test_case[2].is_a?(Proc); test_case
# end
# test_cases.each { |test_case| puts "#{test_case.inspect} => []," }; nil
