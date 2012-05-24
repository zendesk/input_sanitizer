require 'input_sanitizer/default_converters'

class InputSanitizer::Sanitizer
  def initialize(data)
    @data = symbolize_keys(data)
  end

  def cleaned
    ret = {}
    self.class.fields.each do |field, type|
      converter = type.respond_to?(:call) ? type : self.class.converters[type]
      if @data.has_key?(field)
        begin
          value = converter.call(@data[field])
          ret[field] = value
        rescue InputSanitizer::ConversionError
        end
      end
    end
    ret
  end

  def self.converters
    {
      :integer => InputSanitizer::IntegerConverter.new,
      :string => InputSanitizer::StringConverter.new,
      :date => InputSanitizer::DateConverter.new,
      :time => InputSanitizer::TimeConverter.new,
      :boolean => InputSanitizer::BooleanConverter.new,
    }
  end

  def self.fields
    @@fields ||= {}
  end

  def self.string(*keys)
    set_keys_to_type(keys, :string)
  end

  def self.integer(*keys)
    set_keys_to_type(keys, :integer)
  end

  def self.boolean(*keys)
    set_keys_to_type(keys, :boolean)
  end

  def self.custom(*keys)
    options = keys.pop
    converter = options[:converter]
    self.set_keys_to_type(keys, converter)
  end

  def self.date(*keys)
    set_keys_to_type(keys, :date)
  end

  def self.time(*keys)
    set_keys_to_type(keys, :time)
  end

  private
  def symbolize_keys(data)
    ret = {}
    data.each do |key, value|
      ret[key.to_sym] = value
    end
    ret
  end

  def self.set_keys_to_type(keys, type)
    keys.each do |key|
      fields[key] = type
    end
  end

end
