module InputSanitizer
  class RestrictedHash < Hash
    def initialize(allowed_keys)
      @allowed_keys = allowed_keys
      super() { |hash, key| default_for_key(key) }
    end

    def key_allowed?(key)
      @allowed_keys.include?(key)
    end

    def transform_keys
      return enum_for(:transform_keys) unless block_given?
      new_allowed_keys = @allowed_keys.map { |key| yield(key) }
      result = self.class.new(new_allowed_keys)
      each_key do |key|
        result[yield(key)] = self[key]
      end
      result
    end

    def transform_keys!
      return enum_for(:transform_keys!) unless block_given?
      @allowed_keys.map! { |key| yield(key) }
      keys.each do |key|
        self[yield(key)] = delete(key)
      end
      self
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
