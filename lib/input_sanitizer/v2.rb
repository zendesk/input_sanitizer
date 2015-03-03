module InputSanitizer::V2
end

dir = File.dirname(__FILE__)
require File.join(dir, 'v2/types')
require File.join(dir, 'v2/clean_payload_collection_field')
require File.join(dir, 'v2/clean_query_collection_field')
require File.join(dir, 'v2/clean_field')
require File.join(dir, 'v2/error_collection')
require File.join(dir, 'v2/payload_sanitizer')
require File.join(dir, 'v2/query_sanitizer')
require File.join(dir, 'v2/payload_transform')
