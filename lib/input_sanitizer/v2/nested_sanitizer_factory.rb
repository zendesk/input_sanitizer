class InputSanitizer::V2::NestedSanitizerFactory
  class NilAllowed
    def cleaned
      nil
    end

    def valid?
      true
    end
  end

  def self.for(nested_sanitizer_klass, value, options)
    if value.nil? && options[:allow_nil] && !options[:collection]
      NilAllowed.new
    else
      nested_sanitizer_klass.new(value, options)
    end
  end
end
