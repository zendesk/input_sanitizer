class InputSanitizer::V2::CleanField < MethodStruct.new(:data, :has_key, :default, :collection, :options)
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
      InputSanitizer::V2::CleanCollectionField.call(
        :data => data,
        :collection => collection,
        :options => options
      )
    else
      InputSanitizer::V2::CleanSingleValue.call(options.merge(:data => data))
    end
  end
end
