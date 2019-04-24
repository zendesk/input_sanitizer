require 'active_support/core_ext/object/blank'

module InputSanitizer::V2::Types
  class IntegerCheck
    def call(value, options = {})
      if value == nil && (options[:allow_nil] == false || options[:allow_blank] == false || options[:required] == true)
        raise InputSanitizer::BlankValueError
      elsif value == nil
        value
      else
        Integer(value).tap do |integer|
          raise InputSanitizer::TypeMismatchError.new(value, :integer) unless integer == value
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:minimum] && integer < options[:minimum]
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:maximum] && integer > options[:maximum]
        end
      end
    rescue ArgumentError, TypeError
      raise InputSanitizer::TypeMismatchError.new(value, :integer)
    end
  end

  class CoercingIntegerCheck
    def call(value, options = {})
      if value == nil || value == 'null'
        if options[:allow_nil] == false || options[:allow_blank] == false || options[:required] == true
          raise InputSanitizer::BlankValueError
        else
          nil
        end
      else
        Integer(value).tap do |integer|
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:minimum] && integer < options[:minimum]
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:maximum] && integer > options[:maximum]
        end
      end
    rescue ArgumentError
      raise InputSanitizer::TypeMismatchError.new(value, :integer)
    end
  end

  class FloatCheck
    def call(value, options = {})
      if value == nil && (options[:allow_nil] == false || options[:allow_blank] == false || options[:required] == true)
        raise InputSanitizer::BlankValueError
      elsif value == nil
        value
      else
        Float(value).tap do |float|
          raise InputSanitizer::TypeMismatchError.new(value, :float) unless float == value
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:minimum] && float < options[:minimum]
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:maximum] && float > options[:maximum]
        end
      end
    rescue ArgumentError, TypeError
      raise InputSanitizer::TypeMismatchError.new(value, :float)
    end
  end

  class CoercingFloatCheck
    def call(value, options = {})
      if value == nil || value == 'null'
        if options[:allow_nil] == false || options[:allow_blank] == false || options[:required] == true
          raise InputSanitizer::BlankValueError
        else
          nil
        end
      else
        Float(value).tap do |float|
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:minimum] && float < options[:minimum]
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:maximum] && float > options[:maximum]
        end
      end
    rescue ArgumentError
      raise InputSanitizer::TypeMismatchError.new(value, :float)
    end
  end

  class StringCheck
    def call(value, options = {})
      if options[:allow] && !options[:allow].include?(value)
        raise InputSanitizer::ValueNotAllowedError.new(value)
      elsif value.blank? && (options[:allow_blank] == false || options[:required] == true)
        raise InputSanitizer::BlankValueError
      elsif options[:regexp] && options[:regexp].match(value).nil?
        raise InputSanitizer::RegexpMismatchError.new
      elsif value == nil && options[:allow_nil] == false
        raise InputSanitizer::BlankValueError
      elsif value.blank?
        value
      else
        value.to_s.tap do |string|
          raise InputSanitizer::TypeMismatchError.new(value, :string) unless string == value
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:minimum] && string.length < options[:minimum]
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:maximum] && string.length > options[:maximum]
        end
      end
    end
  end

  class BooleanCheck
    def call(value, options = {})
      if value == nil
        raise InputSanitizer::BlankValueError
      elsif [true, false].include?(value)
        value
      else
        raise InputSanitizer::TypeMismatchError.new(value, :boolean)
      end
    end
  end

  class CoercingBooleanCheck
    def call(value, options = {})
      if [true, 'true'].include?(value)
        true
      elsif [false, 'false'].include?(value)
        false
      else
        raise InputSanitizer::TypeMismatchError.new(value, :boolean)
      end
    end
  end

  class DatetimeCheck
    def initialize(options = {})
      @check_date = options && options[:check_date]
      @klass = @check_date ? Date : DateTime
    end

    def call(value, options = {})
      raise InputSanitizer::TypeMismatchError.new(value, @check_date ? :date : :datetime) unless value == nil || value.is_a?(String)

      if value.blank? && (options[:allow_blank] == false || options[:required] == true)
        raise InputSanitizer::BlankValueError
      elsif value == nil && options[:allow_nil] == false
        raise InputSanitizer::BlankValueError
      elsif value.blank?
        value
      else
        @klass.parse(value).tap do |datetime|
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:minimum] && datetime < options[:minimum]
          raise InputSanitizer::ValueError.new(value, options[:minimum], options[:maximum]) if options[:maximum] && datetime > options[:maximum]
        end
      end
    rescue ArgumentError, TypeError
      raise InputSanitizer::TypeMismatchError.new(value, @check_date ? :date : :datetime)
    end
  end

  class URLCheck
    def call(value, options = {})
      if value.blank? && (options[:allow_blank] == false || options[:required] == true)
        raise InputSanitizer::BlankValueError
      elsif value == nil && options[:allow_nil] == false
        raise InputSanitizer::BlankValueError
      elsif value.blank?
        value
      else
        unless /\A#{URI.regexp(%w(http https)).to_s}\z/.match(value)
          raise InputSanitizer::TypeMismatchError.new(value, :url)
        end
        value
      end
    end
  end

  class SortByCheck
    def call(value, options = {})
      check_options!(options)

      key, direction = split(value)
      direction = 'asc' if direction.blank?

      # special case when fallback takes care of separator sanitization e.g. custom fields
      if options[:fallback] && !allowed_directions.include?(direction)
        direction = 'asc'
        key = value
      end

      unless valid?(key, direction, options)
        raise InputSanitizer::ValueNotAllowedError.new(value)
      end

      [key, direction]
    end

  private
    def valid?(key, direction, options)
      allowed_keys = options[:allow]
      fallback = options[:fallback]

      allowed_directions.include?(direction) &&
        ((allowed_keys && allowed_keys.include?(key)) ||
          (fallback && fallback.call(key, direction, options)))
    end

    def split(value)
      head, _, tail = value.to_s.rpartition(':')
      head.empty? ? [tail, head] : [head, tail]
    end

    def check_options!(options)
      fallback = options[:fallback]
      if fallback && !fallback.respond_to?(:call)
        raise ArgumentError, ":fallback option must respond to method :call (proc, lambda etc)"
      end
    end

    def allowed_directions
      ['asc', 'desc']
    end
  end
end
