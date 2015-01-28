module InputSanitizer
  class RestrictedHash < Hash
    def initialize(allowed_keys)
      @allowed_keys = allowed_keys
      super() { |hash, key| default_for_key(key) }
    end

    def key_allowed?(key)
      @allowed_keys.include?(key)
    end

    private
    def default_for_key(key)
      key_allowed?(key) ? nil : raise_not_allowed(key)
    end

    def raise_not_allowed(key)
      msg = "Key not allowed: #{key}"
      raise KeyNotAllowedError.new(msg)
    end
  end
end
