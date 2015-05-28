module InputSanitizer
  class SpecificValuesConverter
    def initialize(values)
      @valid_values = values
    end

    def call(value)
      case
      when @valid_values.include?(value)
        value
      when value.respond_to?(:to_sym) && @valid_values.include?(value.to_sym)
        value.to_sym
      else
        values_joined = @valid_values.join(", ")
        raise InputSanitizer::ConversionError.new("Possible values: #{values_joined}")
      end
    end
  end
end
