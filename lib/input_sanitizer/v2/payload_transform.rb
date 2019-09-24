require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/json'

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
    # `payload` here meant not to have default proc and before rails 4.2 `.with_indifferent_access` removed it.
    # HashWithIndifferentAccess will copy of orignal hash without default proc only on 1st level keys
    # If value of 1st level key is a RestrictedHash as well, we need to `.as_json` to clean those defaults as well
    @payload ||= HashWithIndifferentAccess[original_payload.as_json]
  end
end
