module InputSanitizer::V1
end

dir = File.dirname(__FILE__)
require File.join(dir, 'errors')
require File.join(dir, 'restricted_hash')
require File.join(dir, 'v1', 'default_converters')
require File.join(dir, 'v1', 'clean_field')
require File.join(dir, 'v1', 'sanitizer')
require File.join(dir, 'extended_converters')

# Backward compatibility
module InputSanitizer
  Sanitizer = V1::Sanitizer

  IntegerConverter = V1::IntegerConverter
  StringConverter = V1::StringConverter
  DateConverter = V1::DateConverter
  TimeConverter = V1::TimeConverter
  BooleanConverter = V1::BooleanConverter
  AllowNil = V1::AllowNil
end
