require 'spec_helper'
require 'input_sanitizer/extended_converters/specific_values_converter'

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
