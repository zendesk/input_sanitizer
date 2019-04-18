class InputSanitizer::V2::QuerySanitizer < InputSanitizer::V2::PayloadSanitizer
  def self.converters
    {
      :integer => InputSanitizer::V2::Types::CoercingIntegerCheck.new,
      :float => InputSanitizer::V2::Types::CoercingFloatCheck.new,
      :string => InputSanitizer::V2::Types::StringCheck.new,
      :boolean => InputSanitizer::V2::Types::CoercingBooleanCheck.new,
      :datetime => InputSanitizer::V2::Types::DatetimeCheck.new,
      :date => InputSanitizer::V2::Types::DatetimeCheck.new(:check_date => true),
      :url => InputSanitizer::V2::Types::URLCheck.new,
    }
  end
  initialize_types_dsl

  def self.sort_by(allowed_values, options = {})
    set_keys_to_converter([:sort_by, { :allow => allowed_values }.merge(options)], InputSanitizer::V2::Types::SortByCheck.new)
  end

  # allow underscore cache buster by default
  string :_

  private
  def perform_clean
    super
    @errors.each do |error|
      error.field = error.field[1..-1] if error.field.start_with?('/')
    end
  end

  def sanitizer_type
    :query
  end
end
