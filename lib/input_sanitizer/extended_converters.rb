module InputSanitizer
  class PositiveIntegerConverter < IntegerConverter
    def call(value)
      super.tap { |value| raise_error if value <= 0 }
    end

    private
    def raise_error
      raise ConversionError.new("invalid integer (neagtive or zero)")
    end
  end

  class CommaJoinedIntegersConverter
    def call(value)
      value = value.to_s
      non_valid = value.gsub(/[0-9,]/, "")

      if non_valid.empty?
        value.split(",").map(&:to_i)
      else
        invalid_chars = non_valid.split(//).join(", ")
        raise InputSanitizer::ConversionError.new("Invalid integers: #{invalid_chars}")
      end
    end
  end

  class CommaJoinedStringsConverter
    def call(value)
      value = value.to_s
      non_valid = value.gsub(/[a-zA-Z,_]/, "")

      if non_valid.empty?
        value.split(",").map(&:to_s)
      else
        invalid_chars = non_valid.split(//).join(", ")
        raise InputSanitizer::ConversionError.new("Invalid strings: #{invalid_chars}")
      end
    end
  end

  class SpecificValuesConverter
    def initialize(values)
      @valid_values = values
    end

    def call(value)
      case
      when @valid_values.include?(value)
        value
      when @valid_values.include?(value.to_sym)
        value.to_sym
      else
        values_joined = @valid_values.join(", ")
        raise InputSanitizer::ConversionError.new("Possible values: #{values_joined}")
      end
    end
  end
end
