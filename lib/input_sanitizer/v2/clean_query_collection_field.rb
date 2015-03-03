class InputSanitizer::V2::CleanQueryCollectionField < MethodStruct.new(:data, :converter, :collection, :options)
  def call
    validate_type
    validate_size

    result, errors = [], {}
    items.each_with_index do |value, idx|
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
  def items
    @items ||= data.to_s.split(',')
  end

  def validate_type
    InputSanitizer::V2::Types::StringCheck.new.call(data)
  end

  def validate_size
    if collection.respond_to?(:fetch)
      if collection[:minimum] && items.length < collection[:minimum]
        raise InputSanitizer::CollectionLengthError.new(items.length, collection[:minimum], collection[:maximum])
      elsif collection[:maximum] && items.length > collection[:maximum]
        raise InputSanitizer::CollectionLengthError.new(items.length, collection[:minimum], collection[:maximum])
      end
    end
  end
end
