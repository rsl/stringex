module Stringex
  module ActsAsUrl
    module Adapter
      class Mongoid < Base
        def create_callbacks!(klass)
          if settings.sync_url
            klass.before_validation :ensure_unique_url
          else
            if defined?(ActiveModel::Callbacks)
              klass.before_validation :ensure_unique_url, :on => :create
            else
              klass.before_validation_on_create :ensure_unique_url
            end
          end

          klass.class_eval <<-"END"
            def #{settings.url_attribute}
              acts_as_url_configuration.adapter.url_attribute self
            end
          END
        end

        def url_attribute(instance)
          if !instance.new_record? && instance.errors[settings.attribute_to_urlify].present?
            instance.class.find(instance.id).send settings.url_attribute
          else
            instance.read_attribute settings.url_attribute
          end
        end

        def self.loadable?
          defined?(::Mongoid) && defined?(::Mongoid::Document)
        end

        def self.load
          ensure_loadable
          ::Mongoid::Document.send :include, Stringex::ActsAsUrl
        end

      private

        def add_new_record_url_owner_conditions
          return if instance.new_record?
          @url_owner_conditions.first << " and id != ?"
          @url_owner_conditions << instance.id
        end

        def add_scoped_url_owner_conditions
          return unless settings.scope_for_url
          @url_owner_conditions.first << " and #{settings.scope_for_url} = ?"
          @url_owner_conditions << instance.send(settings.scope_for_url)
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

        def klass_previous_instances(&block)
          klass.find_each(:conditions => {settings.url_attribute => nil}, &block)
        end

        def url_owner_conditions
          get_base_url_owner_conditions
          add_new_record_url_owner_conditions
          add_scoped_url_owner_conditions

          @url_owner_conditions
        end

        def url_owners
          @url_owners ||= instance.class.unscoped.find(:all, :conditions => url_owner_conditions)
        end
      end
    end
  end
end