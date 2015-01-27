module InputSanitizer::V1
end

require_relative 'errors'
require_relative 'restricted_hash'
require_relative 'v1/default_converters'
require_relative 'v1/clean_field'
require_relative 'v1/sanitizer'
require_relative 'extended_converters'

InputSanitizer::Sanitizer = InputSanitizer::V1::Sanitizer
