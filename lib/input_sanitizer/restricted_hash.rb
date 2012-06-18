class InputSanitizer::RestrictedHash < Hash
  def initialize(allowed_keys)
    @allowed_keys = allowed_keys
    super() do |hash, key|
      if @allowed_keys.include?(key)
        nil
      else
        raise KeyError.new("Key not allowed: #{key}")
      end
    end
  end

end
