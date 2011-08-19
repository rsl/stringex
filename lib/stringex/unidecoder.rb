# encoding: UTF-8
require "yaml"

module Stringex
  module Unidecoder
    # Contains Unicode codepoints, loading as needed from YAML files
    CODEPOINTS = Hash.new{|h, k|
      h[k] = YAML::load_file(File.join(File.expand_path(File.dirname(__FILE__)), "unidecoder_data", "#{k}.yml"))
    } unless defined?(CODEPOINTS)
    LOCAL_CODEPOINTS = Hash.new unless defined?(LOCAL_CODEPOINTS)

    class << self
      # Returns string with its UTF-8 characters transliterated to ASCII ones
      #
      # You're probably better off just using the added String#to_ascii
      def decode(string)
        string.gsub(/[^\x00-\x7f]/u) do |codepoint|
          if localized = local_codepoint(codepoint)
            localized
          else
            begin
              unpacked = codepoint.unpack("U")[0]
              CODEPOINTS[code_group(unpacked)][grouped_point(unpacked)]
            rescue
              # Hopefully this won't come up much
              # TODO: Make this note something to the user that is reportable to me perhaps
              "?"
            end
          end
        end
      end

      # Returns character for the given Unicode codepoint
      def encode(codepoint)
        ["0x#{codepoint}".to_i(16)].pack("U")
      end

      # Returns string indicating which file (and line) contains the
      # transliteration value for the character
      def in_yaml_file(character)
        unpacked = character.unpack("U")[0]
        "#{code_group(unpacked)}.yml (line #{grouped_point(unpacked) + 2})"
      end

      # Adds localized transliterations to Unidecoder
      def localize_from(hash_or_path_to_file)
        hash = if hash_or_path_to_file.is_a?(Hash)
          hash_or_path_to_file
        else
          YAML::load_file(hash_or_path_to_file)
        end
        verify_local_codepoints hash
      end

      # Returns locale for localized transliterations
      def locale
        if @locale
          @locale
        elsif defined?(I18n)
          I18n::locale
        else
          default_locale
        end
      end

      # Sets locale for localized transliterations
      def locale=(new_locale)
        @locale = new_locale
      end

      # Returns default locale for localized transliterations. NOTE: Will set @locale as well.
      def default_locale
        @default_locale ||= "en"
        @locale = @default_locale
      end

      # Sets the default locale for localized transliterations. NOTE: Will set @locale as well.
      def default_locale=(new_locale)
        @default_locale = new_locale
        # Seems logical that @locale should be the new default
        @locale = new_locale
      end

      # Returns the localized transliteration for a codepoint
      def local_codepoint(codepoint)
        locale_hash = LOCAL_CODEPOINTS[locale] || LOCAL_CODEPOINTS[locale.is_a?(Symbol) ? locale.to_s : locale.to_sym]
        locale_hash && locale_hash[codepoint]
      end

      # Runs a block with a temporary locale setting, returning the locale to the original state when complete
      def with_locale(new_locale, &block)
        new_locale = default_locale if new_locale == :default
        original_locale = locale
        self.locale = new_locale
        block.call
        self.locale = original_locale
      end

      # Runs a block with default locale
      def with_default_locale(&block)
        with_locale default_locale, &block
      end

    private
      # Returns the Unicode codepoint grouping for the given character
      def code_group(unpacked_character)
        "x%02x" % (unpacked_character >> 8)
      end

      # Returns the index of the given character in the YAML file for its codepoint group
      def grouped_point(unpacked_character)
        unpacked_character & 255
      end

      # Checks LOCAL_CODEPOINTS's Hash is in the format we expect before assigning it and raises
      # instructive exception if not
      def verify_local_codepoints(hash)
        pass_check = hash.all?{|key, value|
          # Fuck a duck, eh?
          [Symbol, String].include?(key.class) && value.is_a?(Hash) &&
            value.keys.all?{|k| k.is_a?(String)} && value.values.all?{|v| v.is_a?(String)}
        }
        if pass_check
          hash.each do |k, v|
            LOCAL_CODEPOINTS[k] = v
          end
        else
          raise ArgumentError, "LOCAL_CODEPOINTS is not correctly defined. Please see the README for more information on how to correctly format this data."
        end
      end
    end
  end
end

module Stringex
  module StringExtensions
    # Returns string with its UTF-8 characters transliterated to ASCII ones. Example:
    #
    #   "⠋⠗⠁⠝⠉⠑".to_ascii #=> "braille"
    def to_ascii
      Stringex::Unidecoder.decode(self)
    end
  end
end
