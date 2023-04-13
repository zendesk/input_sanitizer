class InputSanitizer::V2::NestedSanitizerFactory
  class NilAllowed
    def cleaned
      nil
    end

    def valid?
      true
    end
  end
  
  class HashExpected
    def initialize(value)
      @value = value
    end
    
    def valid?
      false
    end
    
    def cleaned
      nil
    end
    
    def errors
      [InputSanitizer::TypeMismatchError.new(@value, :hash)]
    end
  end

  def self.for(nested_sanitizer_klass, value, options)
    if value.nil? && options[:allow_nil] && !options[:collection]
      NilAllowed.new
    elsif !value.is_a?(Hash)
      HashExpected.new(value)
    else
      nested_sanitizer_klass.new(value, options)
    end
  end
end
