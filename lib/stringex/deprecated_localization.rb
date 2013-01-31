# This file ensures backwards compatibility for applications using the built in
# localization interface in version 1.x. This functionality is deprecated and will
# be removed in version 2.0.0. Applications should instead move to I18n and use
# this to store translations.
#
# TODO: Link to wiki explaining how to use I18n with Stringex.

module Stringex
  class << self
    %w{
      locale
      locale=
      default_locale
      default_locale=
      with_locale
      with_default_locale
    }.each do |name|
      define_method name do |*args, &block|
        Localization.send name, *args, &block
      end
    end

    %w{
      localize_from
      local_codepoint
    }.each do |name|
      define_method name do |*args, &block|
        Unidecoder.send name, *args, &block
      end
    end
  end

  module Unidecoder
    class << self
      # Adds localized transliterations to Unidecoder
      def localize_from(hash_or_path_to_file)
        hash = if hash_or_path_to_file.is_a?(Hash)
          hash_or_path_to_file
        else
          YAML.load_file(hash_or_path_to_file)
        end
        verify_local_codepoints hash
      end

      # Returns the localized transliteration for a codepoint
      def local_codepoint(codepoint)
        Localization.translate(:transliterations, codepoint)
      end

      %w{
        locale
        locale=
        default_locale
        default_locale=
        with_locale
        with_default_locale
      }.each do |name|
        define_method name do |*args, &block|
          Localization.send name, *args, &block
        end
      end

    private

      # Checks LOCAL_CODEPOINTS's Hash is in the format we expect before assigning it and raises
      # instructive exception if not
      def verify_local_codepoints(hash)
        if !pass_check(hash)
          raise ArgumentError, "LOCAL_CODEPOINTS is not correctly defined. Please see the README for more information on how to correctly format this data."
        end

        hash.each do |locale, data|
          Localization.store_translations locale, :transliterations, data
        end
      end

      def pass_check(hash)
        return false if !hash.is_a?(Hash)
        hash.all? { |key, value| pass_check_key_and_value_test(key, value) }
      end

      def pass_check_key_and_value_test(key, value)
        # Fuck a duck, eh?
        return false unless [Symbol, String].include?(key.class)
        return false unless value.is_a?(Hash)
        value.all? { |k, v| v.is_a?(String) }
      end

    end
  end
end