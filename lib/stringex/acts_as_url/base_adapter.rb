module Stringex
  module ActsAsUrl # :nodoc:
    class BaseAdapter
      attr_reader :config, :instance

      def initialize config, instance
        @config = config
        @instance = instance
      end

      # override if needed
      def handle_duplicate_urls!
        return if allow_duplicates?
                
        if url_owners.any?{|owner| duplicate? owner }          
          n = 1
          while url_owners.any?{|owner| duplicate_with_sep? owner, n }
            n = n.succ
          end
          instance.send :write_attribute, url_attribute, url_with_sep(n)
        end
      end

      protected

      def separator 
        duplicate_count_separator
      end

      def duplicate_with_sep? owner, n
        url_for(owner) == url_with_sep(n)
      end

      def duplicate? owner      
        url_for(owner) == base_url
      end

      def url_with_sep n
        "#{base_url}#{separator}#{n}"
      end

      def url_for owner
        owner.send(url_attribute)
      end

      # define delegates
      [:allow_duplicates?, :duplicate_count_separator, :url_attribute, :scope_for_url].each do |meth| 
        define_method meth do
          config.send(meth)
        end
      end

      def base_url
        @base_url ||= instance.instance_variable_get("@acts_as_url_base_url")
      end      
    end
  end
end