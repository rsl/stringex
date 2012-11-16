# encoding: UTF-8
module Stringex
  module ActsAsUrl # :nodoc:
    def self.included(base)
      base.extend ClassMethods
    end

    class Configuration
      attr_accessor :allow_slash, :allow_duplicates, :attribute_to_urlify, :duplicate_count_separator,
        :exclude, :only_when_blank, :scope_for_url, :sync_url, :url_attribute, :url_limit

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

      def get_conditions!(instance)
        conditions = ["#{url_attribute} LIKE ?", instance.instance_variable_get("@acts_as_url_base_url") + '%']
        unless instance.new_record?
          conditions.first << " and id != ?"
          conditions << instance.id
        end
        if scope_for_url
          conditions.first << " and #{scope_for_url} = ?"
          conditions << instance.send(scope_for_url)
        end
        conditions
      end

      def handle_duplicate_urls!(instance)
        unless allow_duplicates
          base_url = instance.instance_variable_get("@acts_as_url_base_url")

          url_owners = instance.class.unscoped.find(:all, :conditions => get_conditions!(instance))
          if url_owners.any?{|owner| owner.send(url_attribute) == base_url}
            separator = duplicate_count_separator
            n = 1
            while url_owners.any?{|owner| owner.send(url_attribute) == "#{base_url}#{separator}#{n}"}
              n = n.succ
            end
            instance.send :write_attribute, url_attribute, "#{base_url}#{separator}#{n}"
          end
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
      end

      # Initialize the url fields for the records that need it. Designed for people who add
      # <tt>acts_as_url</tt> support once there's already development/production data they'd
      # like to keep around.
      #
      # Note: This method can get very expensive, very fast. If you're planning on using this
      # on a large selection, you will get much better results writing your own version with
      # using pagination.
      def initialize_urls
        find_each(:conditions => {acts_as_url_configuration.url_attribute => nil}) do |instance|
          instance.send :ensure_unique_url
          instance.save
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
