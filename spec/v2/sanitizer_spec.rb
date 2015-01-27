require 'spec_helper'

class TestedSanitizer < InputSanitizer::V2::Sanitizer
  integer :array, :collection => true
  string :status, :allow => ['', 'current', 'past']

  integer :integer_attribute
  string :string_attribute
  boolean :bool_attribute
end

describe InputSanitizer::V2::Sanitizer do
  let(:sanitizer) { TestedSanitizer.new(@params) }
  let(:cleaned) { sanitizer.cleaned }

  describe "collections" do
    it "is invalid if collection is not an array" do
      pending
      @params = { :array => {} }

      sanitizer.should_not be_valid
    end
  end

  describe "allow option" do
    it "is valid when given an allowed string" do
      @params = { :status => 'past' }
      sanitizer.should be_valid
    end

    it "is valid when given an allowed empty string" do
      @params = { :status => '' }
      sanitizer.should be_valid
    end

    it "is invalid when given a disallowed string" do
      @params = { :status => 'current bad string' }
      sanitizer.should_not be_valid
    end
  end

  describe "strict param checking" do
    it "is invalid when given extra params" do
      pending
      @params = { :extra => 'test' }
      sanitizer.should_not be_valid
    end
  end

  describe "strict type checking" do
    it "is invalid when given string instead of integer" do
      @params = { :integer_attribute => '1' }
      sanitizer.should_not be_valid
    end

    it "is invalid when given integer instead of string" do
      @params = { :string_attribute => 0 }
      sanitizer.should_not be_valid
    end

    it "is invalid when given 'yes' as a bool" do
      @params = { :bool_attribute => 'yes' }
      sanitizer.should_not be_valid
    end

    describe "nested checking" do
      it "is invalid when elements of an array are of invalid type" do
        pending
        @params = { :array => [1, 'z', '3', 4] }
        sanitizer.errors[0][:description].should include('index', '1', '2')
      end
    end
  end
end
