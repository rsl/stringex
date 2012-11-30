require 'stringex/acts_as_url/base_adapter' 

if defined?(Mongoid)
  require 'stringex/acts_as_url/mongoid_adapter' 
end

if defined?(ActiveRecord)
  require 'stringex/acts_as_url/active_record_adapter' 
end

# encoding: UTF-8
module Stringex
  module ActsAsUrl # :nodoc:
    extend ActiveSupport::Concern

    included do
    end

    class Configuration
      attr_accessor :allow_slash, :allow_duplicates, :attribute_to_urlify, :duplicate_count_separator,
        :exclude, :only_when_blank, :scope_for_url, :sync_url, :url_attribute, :url_limit

      alias_method :allow_duplicates?, :allow_duplicates
      alias_method :allow_slash?,      :allow_slash
      alias_method :only_when_blank?,  :only_when_blank

      def initialize(klass, options = {})
        self.allow_slash = options[:allow_slash]
        self.allow_duplicates = options[:allow_duplicates]
        self.attribute_to_urlify = options[:attribute]
        self.duplicate_count_separator = options[:duplicate_count_separator] || "-"
        self.exclude = options[:exclude] || []
        self.only_when_blank = options[:only_when_blank]
        self.scope_for_url = options[:scope]
        self.sync_url = options[:sync_url]
        self.url_attribute = options[:url_attribute] || "url"
        self.url_limit = options[:limit]
      end

      def get_base_url!(instance)
        base_url = instance.send(url_attribute)
        if base_url.blank? || !only_when_blank
          root = instance.send(attribute_to_urlify).to_s
          base_url = root.to_url(:allow_slash => allow_slash, :limit => url_limit, :exclude => exclude)
        end
        instance.instance_variable_set "@acts_as_url_base_url", base_url
      end

      def handle_duplicate_urls! instance
        adapter(self, instance).handle_duplicate_urls!
      end

      # Return adapter that fits the instance type
      # Currently supported:
      # - Mongoid models
      # - SQL based models
      def adapter config, instance
        # puts "Find ActsAsUrL model adapter for: #{instance.inspect}"
        if defined?(Mongoid::Document) && instance.kind_of?(Mongoid::Document)
          MongoidAdapter.new config, instance
        elsif defined?(ActiveRecord) && instance.kind_of?(ActiveRecord::Base)
          ActiveRecordAdapter.new config, instance
        else
          raise ArgumentError, "#{instance.class} adapter not yet supported. Please implement your own adapter!"
        end
      end
    end        

    module ClassMethods # :doc:
      # Creates a callback to automatically create an url-friendly representation
      # of the <tt>attribute</tt> argument. Example:
      #
      #   acts_as_url :title
      #
      # will use the string contents of the <tt>title</tt> attribute
      # to create the permalink. <strong>Note:</strong> you can also use a non-database-backed
      # method to supply the string contents for the permalink. Just use that method's name
      # as the argument as you would an attribute.
      #
      # The default attribute <tt>acts_as_url</tt> uses to save the permalink is <tt>url</tt>
      # but this can be changed in the options hash. Available options are:
      #
      # <tt>:allow_slash</tt>:: If true, allow the generated url to contain slashes. Default is false[y].
      # <tt>:allow_duplicates</tt>:: If true, allow duplicate urls instead of appending numbers to
      #                              differentiate between urls. Default is false[y].
      # <tt>:duplicate_count_separator</tt>:: String to use when forcing unique urls from non-unique strings.
      #                                       Default is "-".
      # <tt>:exclude_list</tt>:: List of complete strings that should not be transformed by <tt>acts_as_url</tt>.
      #                          Default is empty.
      # <tt>:only_when_blank</tt>:: If true, the url generation will only happen when <tt>:url_attribute</tt> is
      #                             blank. Default is false[y] (meaning url generation will happen always).
      # <tt>:scope</tt>:: The name of model attribute to scope unique urls to. There is no default here.
      # <tt>:sync_url</tt>:: If set to true, the url field will be updated when changes are made to the
      #                      attribute it is based on. Default is false[y].
      # <tt>:url_attribute</tt>:: The name of the attribute to use for storing the generated url string.
      #                           Default is <tt>:url</tt>.
      # <tt>:url_limit</tt>:: The maximum size a generated url should be. <strong>Note:</strong> this does not
      #                       include the characters needed to enforce uniqueness on duplicate urls.
      #                       Default is nil.
      def acts_as_url(attribute, options = {})
        cattr_accessor :acts_as_url_configuration

        options[:attribute] = attribute
        self.acts_as_url_configuration = ActsAsUrl::Configuration.new(self, options)

        if acts_as_url_configuration.sync_url
          before_validation(:ensure_unique_url)
        else
          if defined?(ActiveModel::Callbacks)
            before_validation(:ensure_unique_url, :on => :create)
          else
            before_validation_on_create(:ensure_unique_url)
          end
        end

        class_eval <<-"END"
          def #{acts_as_url_configuration.url_attribute}
            if !new_record? && errors[acts_as_url_configuration.attribute_to_urlify].present?
              self.class.find(id).send(acts_as_url_configuration.url_attribute)
            else
              read_attribute(acts_as_url_configuration.url_attribute)
            end
          end
        END

        class_eval do
          if defined?(Mongoid::Document) && self.new.kind_of?(Mongoid::Document)
            self.extend MongoidAdapter::ClassMethods
          elsif defined?(ActiveRecord) && self.new.kind_of?(ActiveRecord::Base)
            self.extend ActiveRecordAdapter::ClassMethods
          end
        end
      end
    end

  private

    def ensure_unique_url
      # Just to save some typing
      config = acts_as_url_configuration
      url_attribute = config.url_attribute

      config.get_base_url! self
      write_attribute url_attribute, @acts_as_url_base_url
      config.handle_duplicate_urls!(self) unless config.allow_duplicates
    end
  end
end
