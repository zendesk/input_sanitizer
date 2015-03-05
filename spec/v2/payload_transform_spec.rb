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

    nil
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

  context "when attribute is not present" do
    let(:payload) { {} }

    it "the renamed attribute is not present either" do
      subject.should eq({})
    end
  end

  context "when attribute is nil" do
    let(:payload) { { :value => nil } }

    it "renames it correctly" do
      subject.should eq({ :scope => nil })
    end
  end

  context "when there is no data for a nested transform" do
    let(:payload) { { :name => 'wat' } }

    it "still successfully transforms data" do
      subject.should eq({ :name => 'wat' })
    end
  end

  describe "invalid use of the transform class" do
    subject { InvalidTransform.call(payload) }

    it "raises an error" do
      lambda { subject }.should raise_error
    end
  end
end
