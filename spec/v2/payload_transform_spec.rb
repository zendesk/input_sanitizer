require 'spec_helper'

class AddressTransform < InputSanitizer::V2::PayloadTransform
  def transform
    rename :line1, :street
  end
end

class TestTransform < InputSanitizer::V2::PayloadTransform
  def transform
    rename :value, :scope
    merge_in :address, :using => AddressTransform

    if has?(:thing)
      payload[:other_thing] = "123-#{payload.delete(:thing)}"
    end
  end
end

class InvalidTransform < InputSanitizer::V2::PayloadTransform
  def call
  end
end

describe InputSanitizer::V2::PayloadTransform do
  let(:payload) do
    {
      :name => 'wat',
      :value => 1234,
      :thing => 'zzz',
      :address => {
        :line1 => 'wup wup',
        :city => 'Krakow'
      }
    }
  end

  subject { TestTransform.call(payload) }

  it "returns the transformed payload" do
    subject[:name].should eq('wat')
    subject[:scope].should eq(1234)
    subject[:other_thing].should eq('123-zzz')
    subject[:street].should eq('wup wup')
    subject[:city].should eq('Krakow')

    subject[:value].should be_nil
    subject[:line1].should be_nil
    subject[:address].should be_nil
  end

  describe "invalid use of the transform class" do
    subject { InvalidTransform.call(payload) }

    it "raises an error" do
      lambda { subject }.should raise_error
    end
  end
end
