class InputSanitizer::V2::Sanitizer < InputSanitizer::Sanitizer
  def self.converters
    {
      :integer => InputSanitizer::V2::Types::IntegerCheck.new,
      :string => InputSanitizer::V2::Types::StringCheck.new,
      :boolean => InputSanitizer::V2::Types::BooleanCheck.new,
    }
  end
  initialize_types_dsl

  private
  def clean_field(field, hash)
    super
  rescue InputSanitizer::ValueNotAllowedError => error
    add_error(field, :invalid_value, @data[field], error.message)
  rescue InputSanitizer::TypeMismatchError => error
    add_error(field, :type_mismatch, @data[field], error.message)
  end
end
