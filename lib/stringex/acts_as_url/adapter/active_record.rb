module Stringex
  module ActsAsUrl
    module Adapter
      class ActiveRecord < Base
        def self.loadable?
          defined?(::ActiveRecord) && defined?(::ActiveRecord::Base)
        end

        def self.load
          ensure_loadable
          ::ActiveRecord::Base.send :include, ActsAsUrlInstanceMethods
          ::ActiveRecord::Base.send :extend, ActsAsUrlClassMethods
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