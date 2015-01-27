module InputSanitizer
  class OptionalValueOmitted < StandardError; end

  class KeyNotAllowedError < ArgumentError; end

  class ValidationError < StandardError; end
  class ConversionError < ValidationError; end
  class ValueMissingError < ValidationError; end
  class ValueNotAllowedError < ValidationError; end
  class TypeMismatchError < ValidationError; end
  class NestedError < ValidationError
    attr_reader :nested_errors

    def initialize(nested_errors)
      @nested_errors = nested_errors
    end
  end
  class CollectionError < NestedError; end
end
