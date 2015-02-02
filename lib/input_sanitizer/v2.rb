module InputSanitizer::V2
end

dir = File.dirname(__FILE__)
require File.join(dir, 'v2/types')
require File.join(dir, 'v2/clean_field')
require File.join(dir, 'v2/error_collection')
require File.join(dir, 'v2/sanitizer')