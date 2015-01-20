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
end
