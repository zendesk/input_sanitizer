class InputSanitizer::V2::CleanField < MethodStruct.new(:data, :has_key, :default, :collection, :type, :options)
  def call
    if has_key
      convert
    elsif default
      options[:converter].call(default)
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
        :options => options
      )
    else
      InputSanitizer::V2::CleanSingleValue.call(options.merge(:data => data))
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
