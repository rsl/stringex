module Stringex
  module Configuration
    class Base
      attr_accessor :settings

      def initialize(options = {})
        @settings = OpenStruct.new(default_settings.merge(options))
      end

      # NOTE: This does not cache itself so that instance and class can be cached on the adapter
      # without worrying about thread safety or race conditions
      def adapter
        case settings.adapter
        when :active_record
          Stringex::ActsAsUrl::Adapter::ActiveRecord.new self
        else
          raise ArgumentError, "#{adapter_name} is not a defined ActsAsUrl adapter"
        end
      end

      def default_settings
        {}
      end
    end
  end
end

require "stringex/configuration/acts_as_url"
require "stringex/configuration/string_extensions"
