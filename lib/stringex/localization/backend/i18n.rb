module Stringex
  module Localization
    module Backend
      class I18n < Base
        LOAD_PATH_BASE = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..', '..', 'locales')

        class << self
          def locale
            @locale || ::I18n.locale
          end

          def locale=(new_locale)
            @locale = new_locale
          end

          def default_locale
            ::I18n.default_locale
          end

          def default_locale=(new_locale)
            ::I18n.default_locale = new_locale
          end

          def with_locale(new_locale, &block)
            ::I18n.with_locale new_locale, &block
          end

          def store_translations(locale, scope, data)
            ::I18n.backend.store_translations(locale, { :stringex => { scope => data } })
            reset_translations_cache
          end

          def translations
            # Set up hash like translations[:en][:transliterations]["é"]
            @translations ||= Hash.new { |hsh, locale| hsh[locale] = Hash.new({}).merge(i18n_translations_for(locale)) }
          end

          def initial_translation(scope, key, locale)
            translations[locale][scope][key.to_sym]
          end

          def load_translations(locale = nil)
            locale ||= self.locale
            path = Dir[File.join(LOAD_PATH_BASE, "#{locale}.yml")]
            ::I18n.load_path |= Dir[File.join(LOAD_PATH_BASE, "#{locale}.yml")]
            ::I18n.backend.load_translations
            reset_translations_cache
          end

          def i18n_translations_for(locale)
            ::I18n.translate("stringex", :locale => locale, :default => {})
          end

          def reset_translations_cache
            @translations = nil
          end
        end
      end
    end
  end
end
