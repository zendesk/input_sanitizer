require 'spec_helper'
require 'input_sanitizer/extended_converters/string_without_4byte_chars_converter'

describe InputSanitizer::StringWithout4byteCharsConverter do
  let(:converter) { described_class.new }
  let(:value) { " some \u{1F435} value " }

  it 'strips 4-byte chars' do
    converter.call(value).should eq " some   value "
  end
end
