module InputSanitizer::V2::Types
  class IntegerCheck
    def call(value)
      Integer(value).tap do |integer|
        raise InputSanitizer::TypeMismatchError.new(:integer) unless integer == value
      end
    rescue ArgumentError
      raise InputSanitizer::TypeMismatchError.new(:integer)
    end
  end

  class StringCheck
    def call(value)
      value.to_s.tap do |string|
        raise InputSanitizer::TypeMismatchError.new(:string) unless string == value
      end
    end
  end

  class BooleanCheck
    def call(value)
      if [true, false].include?(value)
        value
      else
        raise InputSanitizer::TypeMismatchError.new(:boolean)
      end
    end
  end
end
