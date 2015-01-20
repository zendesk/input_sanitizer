require 'spec_helper'
require 'input_sanitizer/extended_converters/comma_joined_strings_converter'

describe InputSanitizer::CommaJoinedStringsConverter do
  let(:converter) { described_class.new }

  it "parses to array of ids" do
    converter.call("input,Sanitizer,ROCKS").should == ["input", "Sanitizer", "ROCKS"]
  end

  it "allows underscores" do
    converter.call("input_sanitizer,rocks").should == ["input_sanitizer", "rocks"]
  end

  it "raises on invalid character" do
    lambda { converter.call(":") }.should raise_error(InputSanitizer::ConversionError)
  end
end
