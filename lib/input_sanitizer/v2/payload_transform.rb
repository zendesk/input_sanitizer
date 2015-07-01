class InputSanitizer::V2::PayloadTransform
  attr_reader :original_payload, :context

  def self.call(original_payload, context = {})
    new(original_payload, context).call
  end

  def initialize(original_payload, context = {})
    fail "#{self.class} is missing #transform method" unless respond_to?(:transform)
    @original_payload, @context = original_payload, context
  end

  def call
    transform
    payload
  end


  private
  def rename(from, to)
    if has?(from)
      data = payload.delete(from)
      payload[to] = data
    end
  end

  def merge_in(field, options = {})
    if source = payload.delete(field)
      source = options[:using].call(source) if options[:using]
      payload.merge!(source)
    end
  end

  def has?(key)
    payload.has_key?(key)
  end

  def payload
    @payload ||= original_payload.dup
  end
end
