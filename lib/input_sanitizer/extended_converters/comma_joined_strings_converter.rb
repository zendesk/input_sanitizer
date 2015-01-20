module InputSanitizer
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
end
