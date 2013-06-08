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

        def klass_previous_instances(&block)
          klass.find_each(:conditions => {settings.url_attribute => [nil, '']}, &block)
        end

        def self.orm_class
          ::ActiveRecord::Base
        end
      end
    end
  end
end