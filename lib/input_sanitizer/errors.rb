module InputSanitizer
  class OptionalValueOmitted < StandardError; end

  class KeyNotAllowedError < ArgumentError; end

  class ValidationError < StandardError
    attr_accessor :field
    attr_reader :value
  end

  class ConversionError < ValidationError; end

  class ValueMissingError < ValidationError
    def code
      :value_missing
    end
  end

  class ValueNotAllowedError < ValidationError
    def code
      :invalid_value
    end

    def initialize(value, message = nil)
      @value = value
      @message = message
    end
  end

  class TypeMismatchError < ValidationError
    def code
      :invalid_type
    end

    def initialize(value, type)
      @value = value
      @message = type
    end
  end

  class NestedError < ValidationError
    attr_reader :nested_errors

    def initialize(nested_errors)
      @nested_errors = nested_errors
    end
  end

  class CollectionError < ValidationError
    attr_reader :collection_errors

    def initialize(collection_errors)
      @collection_errors = collection_errors
    end
  end
end
