class InputSanitizer::V2::PayloadTransform < MethodStruct.new(:original_payload)
  def call
    transform
    payload
  end

  def initialize(*args)
    fail "#{self.class} is missing #transform method" unless respond_to?(:transform)
    super
  end

  private
  def rename(from, to)
    payload[to] = payload.delete(from)
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
    @payload ||= original_payload.clone
  end
end
