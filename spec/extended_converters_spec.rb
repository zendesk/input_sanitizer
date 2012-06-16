require 'spec_helper'
require 'input_sanitizer/extended_converters'

describe InputSanitizer::PositiveIntegerConverter do
  let(:converter) { InputSanitizer::PositiveIntegerConverter.new }

  it "raises error if integer less than zero" do
    lambda { converter.call("-3") }.should raise_error(InputSanitizer::ConversionError)
  end

  it "raises error if integer equals zero" do
    lambda { converter.call("0") }.should raise_error(InputSanitizer::ConversionError)
  end
end
