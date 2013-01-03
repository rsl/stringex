module Stringex
  module Configuration
    class StringExtensions < Base
      def default_settings
        self.class.default_settings
      end

      def self.default_settings
        @default_settings ||= {
          :allow_slash => false,
          :exclude => [],
          :limit => nil,
          :force_downcase => true
        }
      end
    end
  end
end