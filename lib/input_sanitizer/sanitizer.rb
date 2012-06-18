require 'input_sanitizer/default_converters'

class InputSanitizer::Sanitizer
  def initialize(data)
    @data = symbolize_keys(data)
    @performed = false
    @errors = []
    @cleaned = {}
  end

  def cleaned
    return @cleaned if @performed
    self.class.fields.each do |field, hash|
      type = hash[:type]
      required = hash[:options][:required]
      clean_field(field, type, required)
    end
    @performed = true
    @cleaned
  end

  def clean_field(field, type, required)
    converter = type.respond_to?(:call) ? type : self.class.converters[type]
    if @data.has_key?(field)
      begin
        value = converter.call(@data[field])
        @cleaned[field] = value
      rescue InputSanitizer::ConversionError => ex
        add_error(field, :invalid_value, @data[field], ex.message)
      end
    else
      add_missing(field, type) if required
    end
  end

  def valid?
    cleaned unless @performed
    @errors.empty?
  end

  def errors
    cleaned unless @performed
    @errors
  end

  def add_error(field, type, value, description = nil)
    @errors << {
      :field => field,
      :type => type,
      :value => value,
      :description => description
    }
  end

  def add_missing(field, type)
    add_error(field, type, nil, nil)
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

  def self.inherited(subclass)
    subclass.fields = self.fields.dup
  end

  def self.fields
    @fields ||= {}
  end

  def self.fields=(new_fields)
    @fields = new_fields
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

  def self.date(*keys)
    set_keys_to_type(keys, :date)
  end

  def self.time(*keys)
    set_keys_to_type(keys, :time)
  end

  def self.custom(*keys)
    options = keys.pop
    converter = options[:converter]
    raise "You did not define a converter for a custom type" if converter == nil
    self.set_keys_to_type(keys, converter)
  end

  def self.extract_options!(array)
    array.last.is_a?(Hash) ? array.pop : {}
  end

  def self.extract_options(array)
    array.last.is_a?(Hash) ? array.last : {}
  end

  private

  def symbolize_keys(data)
    data.inject({}) do |memo, kv|
      memo[kv.first.to_sym] = kv.last
      memo
    end
  end

  def self.set_keys_to_type(keys, type)
    opts = extract_options!(keys)
    keys.each do |key|
      fields[key] = { :type => type, :options => opts }
    end
  end

end
