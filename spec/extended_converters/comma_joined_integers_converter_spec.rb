require 'spec_helper'
require 'input_sanitizer/extended_converters/comma_joined_integers_converter'

describe InputSanitizer::CommaJoinedIntegersConverter do
  let(:converter) { described_class.new }

  it "parses to array of ids" do
    converter.call("1,2,3,5").should eq([1, 2, 3, 5])
  end

  it "converts to array if given an integer" do
    converter.call(7).should eq([7])
  end

  it "raises on invalid character" do
    lambda { converter.call(":") }.should raise_error(InputSanitizer::ConversionError)
  end
end
