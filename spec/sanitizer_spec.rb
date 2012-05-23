require 'spec_helper'

class BasicSanitizer < InputSanitizer::Sanitizer
  string :x, :y, :z
  int :num
  custom :cust1, :cust2, :converter => lambda { |v| v.reverse }
end

describe InputSanitizer::Sanitizer do
  describe "#cleaned" do
    let(:sanitizer) { BasicSanitizer.new(@params) }
    let(:cleaned) { sanitizer.cleaned }

    it "includes specified params" do
      @params = {"x" => 3, "y" => "tom", "z" => "mike"}

      cleaned.should have_key(:x)
      cleaned.should have_key(:y)
      cleaned.should have_key(:z)
    end

    it "strips not specified params" do
      @params = {"d" => 3}

      cleaned.should_not have_key(:d)
    end

    it "includes specified keys and strips rest" do
      @params = {"d" => 3, "x" => "ddd"}

      cleaned.should have_key(:x)
      cleaned.should_not have_key(:d)
    end

    it "works with symbols as input keys" do
      @params = {:d => 3, :x => "ddd"}

      cleaned.should have_key(:x)
      cleaned.should_not have_key(:d)
    end

    it "silently discards cast errors" do
      @params = {:num => "f"}

      cleaned.should_not have_key(:num)
    end
  end

  describe ".custom" do
    let(:sanitizer) { BasicSanitizer.new(@params) }
    let(:cleaned) { sanitizer.cleaned }

    it "converts using custom converter" do
      @params = {:cust1 => "cigam"}

      cleaned.should have_key(:cust1)
      cleaned[:cust1].should == "magic"
    end
  end

  describe ".converters" do
    let(:sanitizer) { InputSanitizer::Sanitizer }

    it "includes :int type" do
      sanitizer.converters.should have_key(:int)
      sanitizer.converters[:int].should be_a(InputSanitizer::IntConverter)
    end

    it "includes :string type" do
      sanitizer.converters.should have_key(:string)
      sanitizer.converters[:string].should be_a(InputSanitizer::StringConverter)
    end

    it "includes :date type" do
      sanitizer.converters.should have_key(:date)
      sanitizer.converters[:date].should be_a(InputSanitizer::DateConverter)
    end
  end
end
