module InputSanitizer
  class PositiveIntegerConverter < IntegerConverter
    def call(value)
      val = super
      raise ConversionError.new("invalid integer (neagtive or zero)") if val <= 0
      val
    end
  end
end
