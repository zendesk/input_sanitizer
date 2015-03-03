require 'spec_helper'

class TestedQuerySanitizer < InputSanitizer::V2::QuerySanitizer
  string :status, :allow => ['', 'current', 'past']

  integer :integer_attribute, :minimum => 1, :maximum => 100, :default => 2
  string :string_attribute
  boolean :bool_attribute
  datetime :datetime_attribute
  url :website

  integer :ids, :collection => true
  string :tags, :collection => true
  sort_by %w(name updated_at created_at)
end

describe InputSanitizer::V2::QuerySanitizer do
  let(:sanitizer) { TestedQuerySanitizer.new(@params) }

  describe 'default value' do
    it 'uses a default value if not provided in params' do
      @params = {}
      sanitizer.should be_valid
      sanitizer[:integer_attribute].should eq(2)
    end
  end

  describe 'type strictness' do
    it 'is valid if given an integer as a string' do
      @params = { :integer_attribute => '22' }
      sanitizer.should be_valid
      sanitizer[:integer_attribute].should eq(22)
    end

    it 'is valid if given a "true" boolean as a string' do
      @params = { :bool_attribute => 'true' }
      sanitizer.should be_valid
      sanitizer[:bool_attribute].should eq(true)
    end

    it 'is valid if given a "false" boolean as a string' do
      @params = { :bool_attribute => 'false' }
      sanitizer.should be_valid
      sanitizer[:bool_attribute].should eq(false)
    end
  end

  describe "minimum and maximum options" do
    it "is invalid if integer is lower than the minimum" do
      @params = { :integer_attribute => 0 }
      sanitizer.should_not be_valid
    end

    it "is invalid if integer is greater than the maximum" do
      @params = { :integer_attribute => 101 }
      sanitizer.should_not be_valid
    end

    it "is valid when integer is within given range" do
      @params = { :integer_attribute => 2 }
      sanitizer.should be_valid
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
      sanitizer.errors[0].field.should eq('status')
    end
  end

  describe "strict param checking" do
    it "is invalid when given extra params" do
      @params = { :extra => 'test', :extra2 => 1 }
      sanitizer.should_not be_valid
      sanitizer.errors.count.should eq(2)
    end

    it "is valid when given an underscore cache buster" do
      @params = { :_ => '1234567890' }
      sanitizer.should be_valid
    end
  end

  describe "strict type checking" do
    it "is valid when given an integer" do
      @params = { :integer_attribute => 50 }
      sanitizer.should be_valid
    end

    it "is valid when given a string" do
      @params = { :string_attribute => '#@!#%#$@#ad' }
      sanitizer.should be_valid
    end

    it "is invalid when given 'yes' as a bool" do
      @params = { :bool_attribute => 'yes' }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('bool_attribute')
    end

    it "is valid when given true as a bool" do
      @params = { :bool_attribute => true }
      sanitizer.should be_valid
    end

    it "is valid when given false as a bool" do
      @params = { :bool_attribute => false }
      sanitizer.should be_valid
    end

    it "is invalid when given an incorrect datetime" do
      @params = { :datetime_attribute => "2014-08-2716:32:56Z" }
      sanitizer.should_not be_valid
      sanitizer.errors[0].field.should eq('datetime_attribute')
    end

    it "is valid when given a correct datetime" do
      @params = { :datetime_attribute => "2014-08-27T16:32:56Z" }
      sanitizer.should be_valid
    end

    it "is valid when given a 'forever' timestamp" do
      @params = { :datetime_attribute => "9999-12-31T00:00:00Z" }
      sanitizer.should be_valid
    end

    it "is valid when given a correct URL" do
      @params = { :website => "https://google.com" }
      sanitizer.should be_valid
    end

    it "is invalid when given an invalid URL" do
      @params = { :website => "ht:/google.com" }
      sanitizer.should_not be_valid
    end

    it "is invalid when given an invalid URL that contains a valid URL" do
      @params = { :website => "watwat http://google.com wat" }
      sanitizer.should_not be_valid
    end
  end

  describe "collections" do
    it "supports comma separated integers" do
      @params = { :ids => "1,2,3" }
      sanitizer.should be_valid
      sanitizer[:ids].should eq([1, 2, 3])
    end

    it "supports comma separated strings" do
      @params = { :tags => "one,two,three" }
      sanitizer.should be_valid
      sanitizer[:tags].should eq(["one", "two", "three"])
    end
  end

  describe "sort_by" do
    it "accepts correct sorting format" do
      @params = { :sort_by => "updated_at:desc" }
      sanitizer.should be_valid
      sanitizer[:sort_by].should eq(["updated_at", "desc"])
    end

    it "assumes ascending order by default" do
      @params = { :sort_by => "name" }
      sanitizer.should be_valid
      sanitizer[:sort_by].should eq(["name", "asc"])
    end
  end
end
