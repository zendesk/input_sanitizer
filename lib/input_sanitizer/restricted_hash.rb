module InputSanitizer
  class RestrictedHash < Hash
    def initialize(allowed_keys)
      @allowed_keys = Set.new(allowed_keys)
      super()
    end

    def [](key)
      raise_not_allowed(key) unless key_allowed?(key)
      fetch(key, nil)
    end

    def []=(key, val)
      @allowed_keys.add(key)
      super
    end

    def store(key, val)
      @allowed_keys.add(key)
      super
    end

    def merge!(hash, &block)
      @allowed_keys.merge(Set[*hash.keys])
      super
    end

    def merge(hash, &block)
      @allowed_keys.merge(Set[*hash.keys])
      super
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

    def raise_not_allowed(key)
      msg = "Key not allowed: #{key}"
      raise KeyNotAllowedError, msg
    end
  end
end
