module Stringex
  module ActsAsUrl
    module Adapter
      class DataMapper < Base
        def self.load
          ensure_loadable
          orm_class.send :include, Stringex::ActsAsUrl::ActsAsUrlInstanceMethods
          ::DataMapper::Model.send :include, Stringex::ActsAsUrl::ActsAsUrlClassMethods
        end

      private

        def add_new_record_url_owner_conditions
          return if instance.new?
          @url_owner_conditions.first << " and id != ?"
          @url_owner_conditions << instance.id
        end

        def add_scoped_url_owner_conditions
          return unless settings.scope_for_url
          @url_owner_conditions.first << " and #{settings.scope_for_url} = ?"
          @url_owner_conditions << instance.send(settings.scope_for_url)
        end

        def orm_class
          self.class.orm_class
        end

        def create_callback
          if settings.sync_url
            klass.class_eval do
              before :save, :ensure_unique_url
            end
          else
            klass.class_eval do
              before :create, :ensure_unique_url
            end
          end
        end

        # NOTE: The <tt>instance</tt> here is not the cached instance but a block variable
        # passed from <tt>klass_previous_instances</tt>, just to be clear
        def ensure_unique_url_for!(instance)
          instance.send :ensure_unique_url
          instance.save
        end

        def get_base_url_owner_conditions
          @url_owner_conditions = ["#{settings.url_attribute} LIKE ?", base_url + '%']
        end

        def instance_from_db
          instance.class.get(instance.id)
        end

        def is_blank?(object)
          object.nil? || object == '' || object == []
        end

        def is_new?(object)
          object.new?
        end

        def is_present?(object)
          !object.nil? && object != '' && object != []
        end

        def klass_previous_instances(&block)
          klass.all(:conditions => {settings.url_attribute => nil}).each do |instance|
            yield instance
          end
        end

        def read_attribute(instance, attribute)
          instance.attributes[attribute]
        end

        def url_owner_conditions
          get_base_url_owner_conditions
          add_new_record_url_owner_conditions
          add_scoped_url_owner_conditions

          @url_owner_conditions
        end

        def url_owners
          @url_owners ||= url_owners_class.all(:conditions => url_owner_conditions)
        end

        def read_attribute(instance, name)
          instance.attribute_get name
        end

        def write_attribute(instance, name, value)
          instance.attribute_set name, value
        end

        def self.orm_class
          ::DataMapper::Resource
        end
      end
    end
  end
end