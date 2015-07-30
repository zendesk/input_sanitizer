class InputSanitizer::V2::PayloadSanitizer < InputSanitizer::Sanitizer
  attr_reader :validation_context

  def initialize(data, validation_context = {})
    super data

    self.validation_context = validation_context || {}
  end

  def validation_context=(context)
    raise ArgumentError, "validation_context must be a Hash" unless context && context.is_a?(Hash)
    @validation_context = context
  end

  def error_collection
    @error_collection ||= InputSanitizer::V2::ErrorCollection.new(errors)
  end

  def self.converters
    {
      :integer => InputSanitizer::V2::Types::IntegerCheck.new,
      :string => InputSanitizer::V2::Types::StringCheck.new,
      :boolean => InputSanitizer::V2::Types::BooleanCheck.new,
      :datetime => InputSanitizer::V2::Types::DatetimeCheck.new,
      :date => InputSanitizer::V2::Types::DatetimeCheck.new(:check_date => true),
      :url => InputSanitizer::V2::Types::URLCheck.new,
    }
  end
  initialize_types_dsl

  def self.nested(*keys)
    options = keys.pop
    sanitizer = options.delete(:sanitizer)
    keys.push(options)
    raise "You did not define a sanitizer for nested value" if sanitizer == nil
    converter = lambda { |value, converter_options|
      instance = sanitizer.new(value, converter_options)
      raise InputSanitizer::NestedError.new(instance.errors) unless instance.valid?
      instance.cleaned
    }

    keys << {} unless keys.last.is_a?(Hash)
    keys.last[:nested] = true

    self.set_keys_to_converter(keys, converter)
  end

  private
  def perform_clean
    super
    @data.reject { |key, _| self.class.fields.keys.include?(key) }.each { |key, _| @errors << InputSanitizer::ExtraneousParamError.new("/#{key}") }
  end

  def prepare_options!(options)
    return options if @validation_context.empty?
    intersection = options.keys & @validation_context.keys
    unless intersection.empty?
      message = "validation context and converter options have the same keys: #{intersection}. " \
        "In order to proceed please fix the configuration. " \
        "In the meantime aborting ..."
      raise RuntimeError, message
    end
    options.merge(@validation_context)
  end

  def clean_field(field, hash)
    options = hash[:options].clone
    collection = options.delete(:collection)
    default = options.delete(:default)
    value = @data[field]
    has_key = @data.has_key?(field)

    if options.delete(:nested) && has_key
      if collection
        raise InputSanitizer::TypeMismatchError.new(value, "array") unless value.is_a?(Array)
      else
        raise InputSanitizer::TypeMismatchError.new(value, "hash") unless value.is_a?(Hash)
      end
    end

    @cleaned[field] = InputSanitizer::V2::CleanField.call(
      :data => value,
      :has_key => has_key,
      :default => default,
      :collection => collection,
      :type => sanitizer_type,
      :converter => hash[:converter],
      :options => prepare_options!(options)
    )
  rescue InputSanitizer::OptionalValueOmitted
  rescue InputSanitizer::ValidationError => error
    @errors += handle_error(field, error)
  end

  def handle_error(field, error)
    case error
    when InputSanitizer::CollectionError
      error.collection_errors.map do |index, error|
        handle_error("#{field}/#{index}", error)
      end
    when InputSanitizer::NestedError
      error.nested_errors.map do |error|
        handle_error("#{field}#{error.field}", error)
      end
    else
      error.field = "/#{field}"
      Array(error)
    end.flatten
  end

  def sanitizer_type
    :payload
  end
end
