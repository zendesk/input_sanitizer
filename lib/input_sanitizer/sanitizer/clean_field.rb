CleanField = MethodStruct.new(:data, :has_key, :field, :type, :required, :collection, :namespace, :default, :provide) do
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
      data.map { |value| convert_single(value) }
    else
      convert_single(data)
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
    if provide
      converter.call(value, provide)
    else
      converter.call(value)
    end
  end

  def converter
    type.respond_to?(:call) ? type : InputSanitizer::Sanitizer.converters[type]
  end
end
