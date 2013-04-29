module Stringex
  module Localization
    module Backend
      module I18n
        LOAD_PATH_BASE = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..', '..', 'locales')

        class << self
          def locale
            ::I18n.locale
          end

          def locale=(new_locale)
            ::I18n.locale = new_locale
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
          end

          def initial_translation(scope, key, locale)
            ::I18n.translate(key, :scope => [:stringex, scope], :locale => locale, :default => "")
          end

          def load_translations(locale = nil)
            locale ||= ::I18n.locale
            ::I18n.load_path << Dir[File.join(LOAD_PATH_BASE, "#{locale}.yml")]
            ::I18n.backend.load_translations
          end

          def reset!
            # Can't reset I18n. Needed?
          end
        end
      end
    end
  end
end