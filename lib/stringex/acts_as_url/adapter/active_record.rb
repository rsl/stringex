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
          if block_given?
            klass.find_in_batches do |records|
              records.each { |record| yield record }
            end
          else
            klass.enum_for :find_each, options do
              options[:start] ? where(table[primary_key].gteq(options[:start])).size : size
            end
          end
        end

        def self.orm_class
          ::ActiveRecord::Base
        end
      end
    end
  end
end
