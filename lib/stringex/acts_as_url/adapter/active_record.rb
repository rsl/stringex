module Stringex
  module ActsAsUrl
    module Adapter
      class ActiveRecord < Base
        def self.load
          ensure_loadable
          orm_class.send :include, ActsAsUrlInstanceMethods
          orm_class.send :extend, ActsAsUrlClassMethods
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

        def orm_class
          self.class.orm_class
        end

        def create_callback
          if settings.sync_url
            klass.before_validation :ensure_unique_url
          else
            klass.before_validation :ensure_unique_url, :on => :create
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
          @url_owners ||= url_owners_class.unscoped.where(url_owner_conditions)
        end

        def self.orm_class
          ::ActiveRecord::Base
        end
      end
    end
  end
end