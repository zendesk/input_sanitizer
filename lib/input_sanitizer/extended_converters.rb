module InputSanitizer
  class PositiveIntegerConverter < IntegerConverter
    def call(value)
      val = super
      raise ConversionError.new("invalid integer (neagtive or zero)") if val <= 0
      val
    end
  end

  class CommaJoinedIntegersConverter
    def call(value)
      value = value.to_s
      non_valid = value.gsub(/[0-9,]/, "")
      if non_valid.empty?
        parts = value.split(",").map(&:to_i)
      else
        invalid_chars = non_valid.split(//)
        invalid_chars_desc = invalid_chars.join(", ")
        raise InputSanitizer::ConversionError.new("Invalid integers: #{invalid_chars_desc}")
      end
    end
  end

  class CommaJoinedStringsConverter
    def call(value)
      value = value.to_s
      non_valid = value.gsub(/[a-zA-Z,_]/, "")
      if non_valid.empty?
        parts = value.split(",").map(&:to_s)
      else
        invalid_chars = non_valid.split(//)
        invalid_chars_desc = invalid_chars.join(", ")
        raise InputSanitizer::ConversionError.new("Invalid strings: #{invalid_chars_desc}")
      end
    end
  end

  class SpecificValuesConverter
    def initialize(values)
      @valid_values = values
    end

    def call(value)
      found = @valid_values.include?(value) ? value : nil
      if !found
        found = @valid_values.include?(value.to_sym) ? value.to_sym : nil
      end
      if !found
        values_joined = @valid_values.join(", ")
        error_message = "Possible values: #{values_joined}"
        raise InputSanitizer::ConversionError.new(error_message)
      else
        found
      end
    end
  end
end
