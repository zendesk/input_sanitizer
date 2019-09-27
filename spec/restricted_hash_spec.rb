require 'spec_helper'

describe InputSanitizer::RestrictedHash do
  let(:hash) { InputSanitizer::RestrictedHash.new([:a]) }

  it 'does not allow bad keys' do
    lambda{ hash[:b] }.should raise_error(InputSanitizer::KeyNotAllowedError)
  end

  it 'does allow correct keys' do
    hash[:a].should be_nil
  end

  it 'returns value for correct key' do
    hash[:a] = 'stuff'
    hash[:a].should == 'stuff'
  end

  it 'allows to set value for a new key' do
    hash[:b] = 'other stuff'
    hash[:b].should == 'other stuff'
    hash.key_allowed?(:b).should be_truthy
  end

  it 'adds new allowed keys after `transform_keys` is done' do
    hash[:a] = 'stuff'
    hash.transform_keys! { |key| key.to_s }
    hash['a'].should == 'stuff'
    hash.key_allowed?('a').should be_truthy
  end

  it 'removes previous allowed keys after `transform_keys` is done' do
    hash[:a] = 'stuff'
    hash.transform_keys! { |key| key.to_s }
    lambda{ hash[:a] }.should raise_error(InputSanitizer::KeyNotAllowedError)
  end

  it 'updates allowed keys on merge!' do
    merge_hash = { merged: '1' }
    hash.merge!(merge_hash)
    hash.key_allowed?(:merged).should be_truthy
  end

  it 'updates allowed keys on merge' do
    merge_hash = { merged: '1' }
    new_hash = hash.merge(some_key: merge_hash)
    new_hash.key_allowed?(:some_key).should be_truthy
  end
end
