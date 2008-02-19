require "yaml"

module LuckySneaks
  module Unidecoder
    # Contains Unicode codepoints, loading as needed from YAML files
    CODEPOINTS = Hash.new { |h, k|
      h[k] = YAML::load_file(File.join(File.dirname(__FILE__), "unidecoder_data", "#{k}.yml"))
    } unless defined?(CODEPOINTS)
  
    class << self
      # Returns string with its UTF-8 characters transliterated to ASCII ones
      # 
      # You're probably better off just using the added String#to_ascii
      def decode(string)
        string.gsub(/[^\x00-\x7f]/u) do |codepoint|
          begin
            CODEPOINTS[code_group(codepoint)][grouped_point(codepoint)]
          rescue
            # Hopefully this won't come up much
            "?"
          end
        end
      end
    
    private
      # Returns the Unicode codepoint grouping for the given character
      def code_group(character)
        "x%02x" % (character.unpack("U")[0] >> 8)
      end
    
      # Returns the index of the given character in the YAML file for its codepoint group
      def grouped_point(character)
        character.unpack("U")[0] & 255
      end
    end
  end
end

class String
  # Returns string with its UTF-8 characters transliterated to ASCII ones. Example: 
  # 
  #   "⠋⠗⠁⠝⠉⠑".to_ascii #=> "braille"
  def to_ascii
    LuckySneaks::Unidecoder::decode(self)
  end
end