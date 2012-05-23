require 'spec_helper'

describe InputSanitizer::IntegerConverter do
  let(:converter) { InputSanitizer::IntegerConverter.new }

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

describe InputSanitizer::BooleanConverter do
  let(:converter) { InputSanitizer::BooleanConverter.new }

  it "casts 'true' to true" do
    converter.call('true').should be_true
  end

  it "casts true to true" do
    converter.call(true).should be_true
  end

  it "casts '1' to true" do
    converter.call('1').should be_true
  end

  it "casts 'yes' to true" do
    converter.call('yes').should be_true
  end

  it "casts 'false' to false" do
    converter.call('false').should be_false
  end

  it "casts false to false" do
    converter.call(false).should be_false
  end

  it "casts '0' to false" do
    converter.call('0').should be_false
  end

  it "casts 'no' to false" do
    converter.call('no').should be_false
  end

  it "raises error if cannot cast" do
    lambda { converter.call("notboolean") }.should raise_error(InputSanitizer::ConversionError)
  end
end
