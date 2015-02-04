class InputSanitizer::V2::QuerySanitizer < InputSanitizer::V2::PayloadSanitizer
  def self.converters
    {
      :integer => InputSanitizer::V2::Types::CoercingIntegerCheck.new,
      :string => InputSanitizer::V2::Types::StringCheck.new,
      :boolean => InputSanitizer::V2::Types::CoercingBooleanCheck.new,
      :datetime => InputSanitizer::V2::Types::DatetimeCheck.new,
      :url => InputSanitizer::V2::Types::URLCheck.new,
    }
  end
  initialize_types_dsl

  # allow underscore cache buster by default
  string :_
end
