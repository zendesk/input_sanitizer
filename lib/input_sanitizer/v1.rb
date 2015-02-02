module InputSanitizer::V1
end

dir = File.dirname(__FILE__)
require File.join(dir, 'errors')
require File.join(dir, 'restricted_hash')
require File.join(dir, 'v1', 'default_converters')
require File.join(dir, 'v1', 'clean_field')
require File.join(dir, 'v1', 'sanitizer')
require File.join(dir, 'extended_converters')

InputSanitizer::Sanitizer = InputSanitizer::V1::Sanitizer
InputSanitizer::AllowNil = InputSanitizer::V1::AllowNil
