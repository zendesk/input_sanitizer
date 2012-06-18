module InputSanitizer
  class KeyNotAllowedError < ArgumentError; end

  class RestrictedHash < Hash
    def initialize(allowed_keys)
      @allowed_keys = allowed_keys

      super() do |hash, key|
        raise_not_allowed(key) unless key_allowed?(key)
        nil
      end
    end

    def key_allowed?(key)
      @allowed_keys.include?(key)
    end

    private
    def raise_not_allowed(key)
      msg = "Key not allowed: #{key}"
      raise KeyNotAllowedError.new(msg)
    end
  end
end
