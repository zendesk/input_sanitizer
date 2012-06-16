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
      non_valid = value.gsub(/[0-9,]/, "")
      if non_valid.empty?
        parts = value.split(",").map(&:to_i)
      else
        invalid_chars = non_valid.split(//)
        invalid_chars_desc = invalid_chars.join(", ")
        raise InputSanitizer::ConversionError.new("Invalid chars: #{invalid_chars_desc}")
      end
    end
  end
end
