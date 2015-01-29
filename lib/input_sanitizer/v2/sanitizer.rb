class InputSanitizer::V2::Sanitizer < InputSanitizer::Sanitizer
  def cleaned
    return @cleaned if @performed

    self.class.fields.each { |field, hash| clean_field(field, hash) }

    @data
      .reject { |key, _| self.class.fields.keys.include?(key) }
      .each { |key, _| @errors << InputSanitizer::ExtraneousParamError.new("/#{key}") }

    @performed = true
    @cleaned.freeze
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
    }
  end
  initialize_types_dsl

  def self.nested(*keys)
    options = keys.pop
    sanitizer = options.delete(:sanitizer)
    keys.push(options)
    raise "You did not define a sanitizer for nested value" if sanitizer == nil
    converter = lambda { |value|
      instance = sanitizer.new(value)
      raise InputSanitizer::NestedError.new(instance.errors) unless instance.valid?
      instance.cleaned
    }
    self.set_keys_to_converter(keys, converter)
  end

  private
  def clean_field(field, hash)
    @cleaned[field] = InputSanitizer::V2::CleanField.call(hash[:options].merge(
      :has_key => @data.has_key?(field),
      :data => @data[field],
      :converter => hash[:converter],
      :provide => @data[hash[:options][:provide]],
    ))
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
end
