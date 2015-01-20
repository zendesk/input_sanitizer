module InputSanitizer
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
end
