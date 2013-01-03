module Stringex
  module Configuration
    class ActsAsUrl < Base
      def initialize(options = {})
        if options[:scope]
          options[:scope_for_url] = options.delete(:scope)
        end

        super
      end

      def string_extensions_settings
        [:allow_slash, :exclude, :force_downcase, :limit].inject(Hash.new){|m, x| m[x] = settings.send(x); m}
      end

      def self.settings
        @settings
      end

    private

      def default_settings
        Stringex::Configuration::StringExtensions.new.default_settings.merge(default_settings)
      end

      def default_settings
        self.class.default_settings
      end

      def self.default_settings
        @default_settings ||= {
          :allow_duplicates => false,
          :duplicate_count_separator => "-",
          :only_when_blank => false,
          :scope_for_url => nil,
          :sync_url => false,
          :url_attribute => "url",
        }
      end
    end
  end
end