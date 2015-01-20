require 'spec_helper'
require 'input_sanitizer/extended_converters/positive_integer_converter'

describe InputSanitizer::PositiveIntegerConverter do
  let(:converter) { InputSanitizer::PositiveIntegerConverter.new }

  it "casts string to integer" do
    converter.call("3").should == 3
  end

  it "raises error if integer less than zero" do
    lambda { converter.call("-3") }.should raise_error(InputSanitizer::ConversionError)
  end

  it "raises error if integer equals zero" do
    lambda { converter.call("0") }.should raise_error(InputSanitizer::ConversionError)
  end
end
