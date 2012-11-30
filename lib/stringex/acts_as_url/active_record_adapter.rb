module Stringex
  module ActsAsUrl # :nodoc:
    class ActiveRecordAdapter < BaseAdapter
      module ClassMethods
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

      protected

      def url_owners
        @url_owners ||= instance.class.unscoped.find(:all, :conditions => conditions)
      end

      def conditions
        @conditions ||= begin
          search_conditions = ["#{url_attribute} LIKE ?", base_url + '%']
          unless instance.new_record?
            search_conditions.first << " and id != ?"
            search_conditions << instance.id
          end
          if scope_for_url
            search_conditions.first << " and #{scope_for_url} = ?"
            search_conditions << instance.send(scope_for_url)
          end
          search_conditions
        end
      end
    end
  end
end