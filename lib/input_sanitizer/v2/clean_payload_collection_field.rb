class InputSanitizer::V2::CleanPayloadCollectionField < MethodStruct.new(:data, :converter, :collection, :options)
  def call
    return nil if options[:allow_nil] && data == nil

    validate_type
    validate_size

    result, errors = [], {}

    data.each_with_index do |value, idx|
      begin
        result << converter.call(value, options)
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
