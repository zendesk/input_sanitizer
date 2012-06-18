require "spec_helper"

describe InputSanitizer::RestrictedHash do
  let(:hash) { InputSanitizer::RestrictedHash.new([:a, :b]) }
  subject { hash }

  it "does not allow bad keys" do
    lambda{hash[:c]}.should raise_error(InputSanitizer::KeyNotAllowedError)
  end

  it "does allow correct keys" do
    hash[:a].should be_nil
  end

  it "returns value for correct key" do
    hash[:a] = 'stuff'
    hash[:a].should == 'stuff'
  end
end
