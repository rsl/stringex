module Stringex
  module Configuration
    class StringExtensions < Base
      def default_settings
        {
          :allow_slash => false,
          :exclude => [],
          :limit => nil
        }
      end
    end
  end
end