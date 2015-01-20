require 'spec_helper'
require 'input_sanitizer/extended_converters'

describe InputSanitizer::AllowNil do
  it "passes blanks" do
    lambda { |_| 1 }.extend(InputSanitizer::AllowNil).call("").should be_nil
  end

  it "passes things the extended sanitizer passes" do
    lambda { |_| :something }.extend(InputSanitizer::AllowNil).call(:stuff).
      should eq(:something)
  end

  it "raises error if the extended sanitizer raises error" do
    action = lambda do
      lambda { |_| raise "Some error" }.extend(InputSanitizer::AllowNil).call(:stuff)
    end

    action.should raise_error
  end
end

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

describe InputSanitizer::CommaJoinedIntegersConverter do
  let(:converter) { InputSanitizer::CommaJoinedIntegersConverter.new }

  it "parses to array of ids" do
    converter.call("1,2,3,5").should == [1, 2, 3, 5]
  end

  it "converts to array if given an integer" do
    converter.call(7).should == [7]
  end

  it "raises on invalid character" do
    lambda { converter.call(":") }.should raise_error(InputSanitizer::ConversionError)
  end
end

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
