class InputSanitizer::V2::CleanField < MethodStruct.new(:data, :has_key, :default, :collection, :type, :converter, :options)
  def call
    if has_key
      convert
    elsif default
      converter.call(default, options)
    elsif options[:required]
      raise InputSanitizer::ValueMissingError
    else
      raise InputSanitizer::OptionalValueOmitted
    end
  end

  private
  def convert
    if collection
      collection_clean.call(
        :data => data,
        :collection => collection,
        :converter => converter,
        :options => options
      )
    else
      converter.call(data, options)
    end
  end

  def collection_clean
    case type
    when :payload
      InputSanitizer::V2::CleanPayloadCollectionField
    when :query
      InputSanitizer::V2::CleanQueryCollectionField
    end
  end
end
