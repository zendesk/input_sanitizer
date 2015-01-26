class InputSanitizer::V2::Sanitizer < InputSanitizer::Sanitizer
  private
  def clean_field(field, hash)
    super
  rescue InputSanitizer::ValueNotAllowedError => error
    add_error(field, :invalid_value, @data[field], error.message)
  end
end
