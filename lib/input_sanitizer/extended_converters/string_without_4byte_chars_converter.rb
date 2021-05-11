module InputSanitizer
  class StringWithout4byteCharsConverter
    def call(value)
      strip_4byte_chars(value)
    end

    private

    # Body of this method was copied from Demoji lib, see:
    # https://github.com/taskrabbit/demoji/blob/c1e7a771da2267cbcf46f96ee113ce6824ae12f8/lib/demoji.rb#L39:L50
    def strip_4byte_chars(string)
      "".tap do |output_string|
        # for instead of split and joins for perf
        for i in (0...string.length)
          char = string[i]
          char = 32.chr if char.ord > 65535
          output_string << char
        end
      end
    end
  end
end
