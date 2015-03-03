class InputSanitizer::V2::CleanSingleValue < MethodStruct.new(:data, :converter, :namespace, :allow, :minimum, :maximum, :provide, :allow_nil, :allow_blank, :required)
  def call
    if namespace
      { namespace => convert_value(data[namespace]) }
    else
      convert_value(data)
    end
  end

  private
  def convert_value(value)
    if allow && !allow.include?(value)
      raise InputSanitizer::ValueNotAllowedError.new(value)
    end

    if minimum || maximum
      converter.call(value, :minimum => minimum, :maximum => maximum)
    elsif provide
      converter.call(value, provide)
    elsif allow_nil != nil || allow_blank != nil || required != nil
      converter.call(value, :allow_nil => allow_nil, :allow_blank => allow_blank, :required => required)
    else
      converter.call(value)
    end
  end
end
