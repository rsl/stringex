module Stringex
  module Configuration
    class Base
      attr_accessor :settings

      def initialize(options = {})
        @settings = OpenStruct.new(default_settings.merge(options))
      end

      def default_settings
        {}
      end
    end
  end
end

require "stringex/configuration/acts_as_url"
require "stringex/configuration/string_extensions"
