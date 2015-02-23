module InputSanitizer::V2::Types
  class IntegerCheck
    def call(value, options = {})
      Integer(value).tap do |integer|
        raise InputSanitizer::TypeMismatchError.new(value, :integer) unless integer == value
        raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:minimum] && integer < options[:minimum]
        raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:maximum] && integer > options[:maximum]
      end
    rescue ArgumentError, TypeError
      raise InputSanitizer::TypeMismatchError.new(value, :integer)
    end
  end

  class CoercingIntegerCheck
    def call(value, options = {})
      Integer(value).tap do |integer|
        raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:minimum] && integer < options[:minimum]
        raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:maximum] && integer > options[:maximum]
      end
    rescue ArgumentError
      raise InputSanitizer::TypeMismatchError.new(value, :integer)
    end
  end

  class StringCheck
    def call(value)
      value.to_s.tap do |string|
        raise InputSanitizer::TypeMismatchError.new(value, :string) unless string == value
      end
    end
  end

  class BooleanCheck
    def call(value)
      if [true, false].include?(value)
        value
      else
        raise InputSanitizer::TypeMismatchError.new(value, :boolean)
      end
    end
  end

  class CoercingBooleanCheck
    def call(value)
      if [true, 'true'].include?(value)
        true
      elsif [false, 'false'].include?(value)
        false
      else
        raise InputSanitizer::TypeMismatchError.new(value, :boolean)
      end
    end
  end

  class DatetimeCheck
    def call(value)
      DateTime.parse(value)
    rescue ArgumentError
      raise InputSanitizer::TypeMismatchError.new(value, :datetime)
    end
  end

  class URLCheck
    def call(value)
      unless /\A#{URI.regexp(%w(http https)).to_s}\z/.match(value)
        raise InputSanitizer::TypeMismatchError.new(value, :url)
      end
    end
  end
end
