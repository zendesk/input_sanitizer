class InputSanitizer::V1::Sanitizer
  def initialize(data)
    @data = symbolize_keys(data)
    @performed = false
    @errors = []
    @cleaned = InputSanitizer::RestrictedHash.new(self.class.fields.keys)
  end

  def self.clean(data)
    new(data).cleaned
  end

  def [](field)
    cleaned[field]
  end

  def cleaned
    return @cleaned if @performed

    self.class.fields.each { |field, hash| clean_field(field, hash) }

    @performed = true
    @cleaned.freeze
  end

  def valid?
    cleaned
    @errors.empty?
  end

  def errors
    cleaned
    @errors
  end

  def self.converters
    {
      :integer => InputSanitizer::V1::IntegerConverter.new,
      :string => InputSanitizer::V1::StringConverter.new,
      :date => InputSanitizer::V1::DateConverter.new,
      :time => InputSanitizer::V1::TimeConverter.new,
      :boolean => InputSanitizer::V1::BooleanConverter.new,
      :integer_or_blank => InputSanitizer::V1::IntegerConverter.new.extend(InputSanitizer::V1::AllowNil),
      :string_or_blank => InputSanitizer::V1::StringConverter.new.extend(InputSanitizer::V1::AllowNil),
      :date_or_blank => InputSanitizer::V1::DateConverter.new.extend(InputSanitizer::V1::AllowNil),
      :time_or_blank => InputSanitizer::V1::TimeConverter.new.extend(InputSanitizer::V1::AllowNil),
      :boolean_or_blank => InputSanitizer::V1::BooleanConverter.new.extend(InputSanitizer::V1::AllowNil),
    }
  end

  def self.inherited(subclass)
    subclass.fields = self.fields.dup
  end

  def self.initialize_types_dsl
    converters.keys.each do |name|
      class_eval <<-END
        def self.#{name}(*keys)
          set_keys_to_converter(keys, :#{name})
        end
      END
    end
  end

  initialize_types_dsl

  def self.custom(*keys)
    options = keys.pop
    converter = options.delete(:converter)
    keys.push(options)
    raise "You did not define a converter for a custom type" if converter == nil
    self.set_keys_to_converter(keys, converter)
  end

  def self.nested(*keys)
    options = keys.pop
    sanitizer = options.delete(:sanitizer)
    keys.push(options)
    raise "You did not define a sanitizer for nested value" if sanitizer == nil
    converter = lambda { |value|
      instance = sanitizer.new(value)
      raise InputSanitizer::ConversionError.new(instance.errors) unless instance.valid?
      instance.cleaned
    }
    self.set_keys_to_converter(keys, converter)
  end

  protected
  def self.fields
    @fields ||= {}
  end

  def self.fields=(new_fields)
    @fields = new_fields
  end

  private
  def self.extract_options!(array)
    array.last.is_a?(Hash) ? array.pop : {}
  end

  def clean_field(field, hash)
    @cleaned[field] = InputSanitizer::V1::CleanField.call(hash[:options].merge({
      :has_key => @data.has_key?(field),
      :data => @data[field],
      :converter => hash[:converter],
      :provide => @data[hash[:options][:provide]],
    }))
  rescue InputSanitizer::ConversionError => error
    add_error(field, :invalid_value, @data[field], error.message)
  rescue InputSanitizer::ValueMissingError => error
    add_error(field, :missing, nil, nil)
  rescue InputSanitizer::OptionalValueOmitted
  end

  def add_error(field, error_type, value, description = nil)
    @errors << {
      :field => field,
      :type => error_type,
      :value => value,
      :description => description
    }
  end

  def symbolize_keys(data)
    data.inject({}) do |memo, kv|
      memo[kv.first.to_sym] = kv.last
      memo
    end
  end

  def self.set_keys_to_converter(keys, converter_or_type)
    options = extract_options!(keys)
    converter = if converter_or_type.is_a?(Symbol)
      if options.fetch(:strict, true)
        converters[converter_or_type]
      else
        non_strict_converters[converter_or_type]
      end
    else
      converter_or_type
    end

    keys.each do |key|
      fields[key] = {
        :converter => converter,
        :options => options
      }
    end
  end
end
