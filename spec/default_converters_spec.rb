require 'spec_helper'

describe InputSanitizer::IntConverter do
  let(:converter) { InputSanitizer::IntConverter.new }

  it "casts string to integer" do
    converter.call("42").should == 42
  end

  it "casts integer to integer" do
    converter.call(42).should == 42
  end

  it "raises error if cannot cast" do
    lambda { converter.call("f") }.should raise_error(InputSanitizer::ConversionError)
  end
end

describe InputSanitizer::DateConverter do
  let(:converter) { InputSanitizer::DateConverter.new }

  it "casts dates in iso format" do
    converter.call("2012-05-15").should == Date.new(2012, 5, 15)
  end

  it "raises error if cannot cast" do
    lambda { converter.call("2012-02-30") }.should raise_error(InputSanitizer::ConversionError)
  end
end
