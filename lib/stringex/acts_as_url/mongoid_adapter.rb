module Stringex
  module ActsAsUrl # :nodoc:
    class MongoidAdapter  < BaseAdapter
      module ClassMethods
        # Initialize the url fields for the records that need it. Designed for people who add
        # <tt>acts_as_url</tt> support once there's already development/production data they'd
        # like to keep around.
        #
        # Note: This method can get very expensive, very fast. If you're planning on using this
        # on a large selection, you will get much better results writing your own version with
        # using pagination.
        def initialize_urls
          where(:conditions => {acts_as_url_configuration.url_attribute => nil}).each do |instance|
            instance.send :ensure_unique_url
            instance.save
          end
        end
      end

      protected

      def url_owners
        instance.class.unscoped.where(conditions).to_a
      end

      def conditions
        search_conditions = {url_attribute => /#{Regexp.escape(base_url)}.*/}        
        search_conditions.merge!('id' => {'$ne' => base_url}) unless instance.new_record?
        search_conditions.merge!(:"#{scope_for_url}" => base_url) if scope_for_url
        search_conditions
      end
    end
  end
end