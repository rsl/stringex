module Stringex
  module ActsAsUrl
    module Adapter
      class Base
        attr_accessor :base_url, :configuration, :instance, :klass, :settings

        def initialize(configuration)
          ensure_loadable
          self.configuration = configuration
          self.settings = configuration.settings
        end

        def create_callbacks!(klass)
          self.klass = klass
          create_method_to_callback
          create_callback
        end

        def ensure_unique_url!(instance)
          @url_owners = nil
          self.instance = instance

          handle_url!
          handle_duplicate_url! unless settings.allow_duplicates
        end

        def initialize_urls!(klass)
          self.klass = klass
          klass_previous_instances do |instance|
            ensure_unique_url_for! instance
          end
        end

        def url_attribute(instance)
          # Retrieve from database record if there are errors on attribute_to_urlify
          if !is_new?(instance) && is_present?(instance.errors[settings.attribute_to_urlify])
            self.instance = instance
            read_attribute instance_from_db, settings.url_attribute
          else
            read_attribute instance, settings.url_attribute
          end
        end

        def self.ensure_loadable
          raise "The #{self} adapter cannot be loaded" unless loadable?
          Stringex::ActsAsUrl::Adapter.add_loaded_adapter self
        end

        def self.loadable?
          orm_class
        rescue NameError
          false
        end

      private

        def create_method_to_callback
          klass.class_eval <<-"END"
            def #{settings.url_attribute}
              acts_as_url_configuration.adapter.url_attribute self
            end
          END
        end

        def duplicate_for_base_url(n)
          "#{base_url}#{settings.duplicate_count_separator}#{n}"
        end

        def ensure_loadable
          self.class.ensure_loadable
        end

        def handle_duplicate_url!
          return if url_owners.none?{|owner| url_attribute_for(owner) == base_url}
          n = 1
          while url_owners.any?{|owner| url_attribute_for(owner) == duplicate_for_base_url(n)}
            n = n.succ
          end
          write_url_attribute duplicate_for_base_url(n)
        end

        def handle_url!
          self.base_url = instance.send(settings.url_attribute)
          modify_base_url if is_blank?(base_url) || !settings.only_when_blank
          write_url_attribute base_url
        end

        def instance_from_db
          instance.class.find(instance.id)
        end

        def is_blank?(object)
          object.blank?
        end

        def is_new?(object)
          object.new_record?
        end

        def is_present?(object)
          object.present?
        end

        def loadable?
          self.class.loadable?
        end

        def modify_base_url
          root = instance.send(settings.attribute_to_urlify).to_s
          self.base_url = root.to_url(configuration.string_extensions_settings)
        end

        def read_attribute(instance, attribute)
          instance.read_attribute attribute
        end

        def url_attribute_for(object)
          object.send settings.url_attribute
        end

        def url_owners_class
          return instance.class unless settings.enforce_uniqueness_on_sti_base_class

          klass = instance.class
          while klass.superclass < orm_class
            klass = klass.superclass
          end
          klass
        end

        def write_attribute(instance, attribute, value)
          instance.send :write_attribute, attribute, value
        end

        def write_url_attribute(value)
          write_attribute instance, settings.url_attribute, value
        end
      end
    end
  end
end
