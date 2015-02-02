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
      :blank
    end

    def initialize
      super("can't be blank")
    end
  end

  class ValueNotAllowedError < ValidationError
    def code
      :inclusion
    end

    def initialize(value)
      @value = value
      super("is not included in the list")
    end
  end

  class TypeMismatchError < ValidationError
    def code
      case @type
      when :integer
        :not_an_integer
      else
        :invalid_type
      end
    end

    def initialize(value, type)
      @value = value
      @type = type

      message = case @type
      when :integer
        "must be an integer"
      else
        "expected a value of type: #{type}"
      end

      super(message)
    end
  end

  class ExtraneousParamError < ValidationError
    def code
      :extraneous_param
    end

    def initialize(name)
      @field = name
      super("undexpected parameter: #{name}")
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
