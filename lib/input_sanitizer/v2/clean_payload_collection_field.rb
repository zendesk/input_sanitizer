class InputSanitizer::V2::CleanPayloadCollectionField < MethodStruct.new(:data, :collection, :options)
  def call
    validate_type
    validate_size

    result, errors = [], {}

    data.each_with_index do |value, idx|
      begin
        result << InputSanitizer::V2::CleanSingleValue.call(options.merge(:data => value))
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

  private
  def validate_type
    unless data.respond_to?(:to_ary)
      raise InputSanitizer::TypeMismatchError.new(data, :array)
    end
  end

  def validate_size
    if collection.respond_to?(:fetch)
      if collection[:minimum] && data.length < collection[:minimum]
        raise InputSanitizer::CollectionLengthError.new(data.length, collection[:minimum], collection[:maximum])
      elsif collection[:maximum] && data.length > collection[:maximum]
        raise InputSanitizer::CollectionLengthError.new(data.length, collection[:minimum], collection[:maximum])
      end
    end
  end
end
