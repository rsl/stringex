# encoding: UTF-8
module Stringex
  module ActsAsUrl # :nodoc:
    def self.included(base)
      base.extend ClassMethods
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
      # <tt>:url_attribute</tt>:: The name of the attribute to use for storing the generated url string.
      #                           Default is <tt>:url</tt>
      # <tt>:scope</tt>:: The name of model attribute to scope unique urls to. There is no default here.
      # <tt>:only_when_blank</tt>:: If true, the url generation will only happen when <tt>:url_attribute</tt> is
      #                             blank. Default is false (meaning url generation will happen always)
      # <tt>:sync_url</tt>:: If set to true, the url field will be updated when changes are made to the
      #                      attribute it is based on. Default is false.
      def acts_as_url(attribute, options = {})
        cattr_accessor :acts_as_url_config
        self.acts_as_url_config = {
          :attribute_to_urlify => attribute,
          :scope_for_url => options[:scope],
          :url_attribute => options[:url_attribute] || "url",
          :only_when_blank => options[:only_when_blank],
          :duplicate_count_separator => options[:duplicate_count_separator] || "-",
          :allow_slash => options[:allow_slash],
          :allow_duplicates => options[:allow_duplicates],
          :url_limit => options[:limit]
        }

        if options[:sync_url]
          before_validation(:ensure_unique_url)
        else
          if defined?(ActiveModel::Callbacks)
            before_validation(:ensure_unique_url, :on => :create)
          else
            before_validation_on_create(:ensure_unique_url)
          end
        end

        class_eval <<-"END"
          def #{acts_as_url_config[:url_attribute]}
            if !new_record? && errors[acts_as_url_config[:attribute_to_urlify]].present?
              self.class.find(id).send(acts_as_url_config[:url_attribute])
            else
              read_attribute(acts_as_url_config[:url_attribute])
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
        find_each(:conditions => {acts_as_url_config[:url_attribute] => nil}) do |instance|
          instance.send :ensure_unique_url
          instance.save
        end
      end

    private

      def setup_acts_as_url_class_accessors
        cattr_accessor :acts_as_url_config

        # cattr_accessor :attribute_to_urlify
        # cattr_accessor :scope_for_url
        # cattr_accessor :url_attribute # The attribute on the DB
        # cattr_accessor :only_when_blank
        # cattr_accessor :duplicate_count_separator
        # cattr_accessor :allow_slash
        # cattr_accessor :allow_duplicates
        # cattr_accessor :url_limit
      end
    end

  private

    def ensure_unique_url
      url_attribute = acts_as_url_config[:url_attribute]
      base_url = send(url_attribute)
      if base_url.blank? || !acts_as_url_config[:only_when_blank]
        base_url = send(acts_as_url_config[:attribute_to_urlify]).to_s
        base_url = base_url.to_url(:allow_slash => acts_as_url_config[:allow_slash], :limit => acts_as_url_config[:url_limit])
      end
      write_attribute url_attribute, base_url
      check_url_duplication
    end

    def check_url_duplication
      unless acts_as_url_config[:allow_duplicates]
        url_attribute = acts_as_url_config[:url_attribute]
        base_url = send(url_attribute)
        separator = acts_as_url_config[:duplicate_count_separator]
        conditions = ["#{url_attribute} LIKE ?", base_url + '%']
        unless new_record?
          conditions.first << " and id != ?"
          conditions << id
        end
        if acts_as_url_config[:scope_for_url]
          conditions.first << " and #{acts_as_url_config[:scope_for_url]} = ?"
          conditions << send(acts_as_url_config[:scope_for_url])
        end
        url_owners = self.class.unscoped.find(:all, :conditions => conditions)
        if url_owners.any?{|owner| owner.send(url_attribute) == base_url}
          n = 1
          while url_owners.any?{|owner| owner.send(url_attribute) == "#{base_url}#{separator}#{n}"}
            n = n.succ
          end
          write_attribute url_attribute, "#{base_url}#{separator}#{n}"
        end
      end
    end
  end
end
