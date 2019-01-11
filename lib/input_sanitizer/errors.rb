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
      :missing
    end

    def initialize
      super("is missing")
    end
  end

  class BlankValueError < ValidationError
    def code
      :blank
    end

    def initialize
      super("can't be blank")
    end
  end

  class RegexpMismatchError < ValidationError
    def code
      :regexp
    end

    def initialize(regexp)
      super("does not match the regular expression: #{regexp}")
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
      when :url
        :invalid_uri
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
      when :url
        'must be a valid URI (include the scheme name part, both http and https are accepted, '\
        'and the hierarchical part)'
      else
        "must be a value of type '#{type}'"
      end

      super(message)
    end
  end

  class ExtraneousParamError < ValidationError
    def code
      :unknown_param
    end

    def initialize(name)
      @field = name
      super("is an unexpected parameter")
    end
  end

  class CollectionLengthError < ValidationError
    def code
      :invalid_length
    end

    def initialize(value, min, max)
      if min && max
        super("must be of length between #{min} and #{max}, given: #{value}")
      elsif min
        super("must be of length greater than or equal to #{min}, given: #{value}")
      else
        super("must be of length less than or equal to #{max}, given: #{value}")
      end
    end
  end

  class ValueError < ValidationError
    def code
      :invalid_value
    end

    def initialize(value, min, max)
      if min && max
        super("must be between #{min} and #{max}, given: #{value}")
      elsif min
        super("must be higher than or equal to #{min}, given: #{value}")
      else
        super("must be lower than or equal to #{max}, given: #{value}")
      end
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
