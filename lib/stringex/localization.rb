module Stringex
  module Localization
    class << self
      attr_accessor :translations

      def translations
        # Set up hash like translations[:en][:transliterations]["é"]
        @translations ||= Hash.new { |k, v| k[v] = Hash.new({}) }
      end

      attr_accessor :backend

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

        if backend == :i18n
          translated = I18n.translate(key, :scope => [:stringex, scope], :locale => locale, :default => "")
        else
          translated = translations[locale][scope][key.to_sym]
        end
        
        if !translated.to_s.empty?
          translated
        elsif locale != default_locale
          translate(scope, key, options.merge(:locale => default_locale))
        else
          options[:default]
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
    end
  end
end