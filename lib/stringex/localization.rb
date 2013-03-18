# encoding: UTF-8

require 'stringex/localization/default_conversions'

module Stringex
  module Localization
    include DefaultConversions

    class << self
      attr_writer :translations, :backend

      def translations
        # Set up hash like translations[:en][:transliterations]["é"]
        @translations ||= Hash.new { |k, v| k[v] = Hash.new({}) }
      end

      def backend
        @backend ||= defined?(I18n) ? :i18n : :internal
      end

      def store_translations(locale, scope, data)
        if backend == :i18n
          I18n.backend.store_translations(locale, { :stringex => { scope => data } })
        else
          self.translations[locale.to_sym][scope.to_sym] = Hash[data.map { |k, v| [k.to_sym, v] }] # Symbolize keys
        end
      end

      def translate(scope, key, options = {})
        return if key == "." # I18n doesn't support dots as translation keys so we don't either

        locale = options[:locale] || self.locale

        translation = initial_translation(scope, key, locale)

        return translation unless translation.to_s.empty?

        if locale != default_locale
          translate scope, key, options.merge(:locale => default_locale)
        else
          default_conversion(scope, key) || options[:default]
        end
      end

      def locale
        if @locale
          @locale
        elsif defined?(I18n)
          I18n.locale
        else
          default_locale
        end
      end

      def locale=(new_locale)
        @locale = new_locale.to_sym
      end

      def default_locale
        if @default_locale
          @default_locale
        elsif defined?(I18n)
          I18n.default_locale
        else
          :en
        end
      end

      def default_locale=(new_locale)
        @default_locale = @locale = new_locale.to_sym
      end

      def with_locale(new_locale, &block)
        new_locale = default_locale if new_locale == :default
        original_locale = locale
        self.locale = new_locale
        block.call
        self.locale = original_locale
      end

      def with_default_locale(&block)
        with_locale default_locale, &block
      end

      def reset!
        @backend = @translations = @locale = @default_locale = nil
      end

    private

      def initial_translation(scope, key, locale)
        if backend == :i18n
          I18n.translate(key, :scope => [:stringex, scope], :locale => locale, :default => "")
        else
          translations[locale][scope][key.to_sym]
        end
      end

      def default_conversion(scope, key)
        return unless Stringex::Localization::DefaultConversions.respond_to?(scope)
        Stringex::Localization::DefaultConversions.send(scope)[key]
      end
    end
  end
end