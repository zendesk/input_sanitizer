class InputSanitizer::V2::ErrorCollection
  include Enumerable

  attr_reader :error_codes, :messages

  def initialize(errors)
    @error_codes = {}
    @messages = {}
    @error_details = {}

    errors.each do |error|
      (@error_codes[error.field] ||= []) << error.code
      (@messages[error.field] ||= []) << error.message
      error_value_hash = { :value => error.value }
      (@error_details[error.field] ||= []) << error_value_hash
    end
  end

  def [](attribute)
    @error_codes[attribute]
  end

  def each
    @error_codes.each_key do |attribute|
      self[attribute].each { |error| yield attribute, error }
    end
  end

  def size
    @error_codes.size
  end
  alias_method :length, :size
  alias_method :count, :size

  def empty?
    @error_codes.empty?
  end

  def add(attribute, code = :invalid, options = {})
    (@error_codes[attribute] ||= []) << code
    (@messages[attribute] ||= []) << options.delete(:messages)
    (@error_details[attribute] ||= []) << options
  end

  def to_hash
    messages.dup
  end
  alias_method :full_messages, :to_hash
end
