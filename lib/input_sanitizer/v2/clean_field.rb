class InputSanitizer::V2::CleanField < MethodStruct.new(
  :data, :has_key, :converter, :required, :collection, :namespace, :default,
  :provide, :allow, :minimum, :maximum)

  def call
    if has_key
      convert
    elsif default
      converter.call(default)
    elsif required
      raise InputSanitizer::ValueMissingError
    else
      raise InputSanitizer::OptionalValueOmitted
    end
  end

  private
  def convert
    if collection
      raise InputSanitizer::TypeMismatchError.new(data, :array) unless data.respond_to?(:to_ary)

      if collection.respond_to?(:fetch)
        if collection[:minimum] && data.length < collection[:minimum]
          raise InputSanitizer::CollectionLengthError.new(data.length, collection[:minimum], collection[:maximum])
        elsif collection[:maximum] && data.length > collection[:maximum]
          raise InputSanitizer::CollectionLengthError.new(data.length, collection[:minimum], collection[:maximum])
        end
      end

      convert_collection(data)
    else
      convert_single(data)
    end
  end

  def convert_collection(values)
    result, errors = [], {}

    values.each_with_index do |value, idx|
      begin
        result << convert_single(value)
      rescue InputSanitizer::ValidationError => e
        errors[idx] = e
      end
    end

    if errors.any?
      raise InputSanitizer::CollectionError.new(errors)
    else
      result
    end
  end

  def convert_single(value)
    if namespace
      { namespace => convert_value(value[namespace]) }
    else
      convert_value(value)
    end
  end

  def convert_value(value)
    raise InputSanitizer::ValueNotAllowedError.new(value) if allow && !allow.include?(value)

    if minimum || maximum
      converter.call(value, :minimum => minimum, :maximum => maximum)
    elsif provide
      converter.call(value, provide)
    else
      converter.call(value)
    end
  end
end
