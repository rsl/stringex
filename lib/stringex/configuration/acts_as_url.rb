module Stringex
  module Configuration
    class ActsAsUrl < Base
      def initialize(options = {})
        if options[:scope]
          options[:scope_for_url] = options.delete(:scope)
        end

        super
      end

      def get_base_url!(instance)
        base_url = instance.send(settings.url_attribute)
        if base_url.blank? || !settings.only_when_blank
          root = instance.send(settings.attribute_to_urlify).to_s
          base_url = root.to_url(string_extensions_settings)
        end
        instance.instance_variable_set "@acts_as_url_base_url", base_url
      end

      def get_conditions!(instance)
        conditions = ["#{settings.url_attribute} LIKE ?", instance.instance_variable_get("@acts_as_url_base_url") + '%']
        unless instance.new_record?
          conditions.first << " and id != ?"
          conditions << instance.id
        end
        if settings.scope_for_url
          conditions.first << " and #{settings.scope_for_url} = ?"
          conditions << instance.send(settings.scope_for_url)
        end
        conditions
      end

      def handle_duplicate_urls!(instance)
        return if settings.allow_duplicates

        base_url = instance.instance_variable_get("@acts_as_url_base_url")
        url_owners = instance.class.unscoped.find(:all, :conditions => get_conditions!(instance))
        if url_owners.any?{|owner| owner.send(settings.url_attribute) == base_url}
          separator = settings.duplicate_count_separator
          n = 1
          while url_owners.any?{|owner| owner.send(settings.url_attribute) == "#{base_url}#{separator}#{n}"}
            n = n.succ
          end
          instance.send :write_attribute, settings.url_attribute, "#{base_url}#{separator}#{n}"
        end
      end

      def default_settings
        Stringex::Configuration::StringExtensions.new.default_settings.merge({
          :allow_duplicates => false,
          :duplicate_count_separator => "-",
          :only_when_blank => false,
          :scope_for_url => nil,
          :sync_url => false,
          :url_attribute => "url",
        })
      end

      def string_extensions_settings
        [:allow_slash, :exclude, :limit].inject(Hash.new){|m, x| m[x] = settings.send(x); m}
      end
    end
  end
end