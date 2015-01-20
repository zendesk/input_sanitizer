require 'spec_helper'
require 'input_sanitizer/extended_converters/specific_values_converter'

describe InputSanitizer::SpecificValuesConverter do
  let(:converter) { described_class.new(values) }
  let(:values) { [:a, :b] }

  it "converts valid value to symbol" do
    converter.call("b").should eq(:b)
  end

  it "raises on invalid value" do
    lambda { converter.call("c") }.should raise_error(InputSanitizer::ConversionError)
  end

  context "when specific values are strings" do
    let(:values) { ["a", "b"] }

    it "keeps given value as string" do
      converter.call("a").should eq("a")
    end
  end
end
