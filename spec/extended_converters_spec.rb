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

describe InputSanitizer::CommaJoinedIntegersConverter do
  let(:converter) { InputSanitizer::CommaJoinedIntegersConverter.new }

  it "parses to array of ids" do
    converter.call("1,2,3,5").should == [1, 2, 3, 5]
  end

  it "raises on invalid character" do
    lambda { converter.call(":") }.should raise_error(InputSanitizer::ConversionError)
  end
end

describe InputSanitizer::SpecificValuesConverter do
  let(:converter) { InputSanitizer::SpecificValuesConverter.new([:a, :b]) }

  it "converts valid value to symbol" do
    converter.call("b").should == :b
  end

  it "raises on invalid value" do
    lambda { converter.call("c") }.should raise_error(InputSanitizer::ConversionError)
  end

  it "converts valid value to string" do
    converter = InputSanitizer::SpecificValuesConverter.new(["a", "b"])
    converter.call("a").should == "a"
  end
end
