# encoding: UTF-8
module Stringex
  module ActsAsUrl # :nodoc:
    def self.options
      [:allow_slash, :allow_duplicates, :attribute_to_urlify, :duplicate_count_separator,
      :exclude, :only_when_blank, :scope_for_url, :sync_url, :url_attribute, :url_limit]
    end
    
    options.each do |option|
      # Getter method for option, using default value as fallback
      (class << self; self; end).send :define_method, option do
        # use default option value if not set
        val = instance_variable_get "@#{option}"
        return val if val
        instance_variable_set "@#{option}", defaults[option.to_sym]
      end

      # Setter method for option
      (class << self; self; end).send :define_method, "#{option}=" do |value|
        instance_variable_set "@#{option}", value
      end
    end

    class << self
      [:allow_slash, :allow_duplicates, :only_when_blank].each do |option|
        define_method "#{option}!" do
          self.send(option, true)
        end
      end

      def defaults
        {
          allow_slash: false,
          allow_duplicates: false,
          attribute_to_urlify: 'title',
          duplicate_count_separator: '-',
          exclude: [],
          only_when_blank: false,
          scope_for_url: nil,
          sync_url: false,
          url_attribute: 'url',
          url_limit: nil
        }
      end

      def config &block
        yield self
      end    
    end
  end
end