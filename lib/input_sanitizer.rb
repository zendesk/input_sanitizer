require "input_sanitizer/version"
module InputSanitizer
  class ParameterError < Exception
  end
  class RequiredParameterMissingError < ParameterError
  end
  # Your code goes here...
end

require 'input_sanitizer/sanitizer'
