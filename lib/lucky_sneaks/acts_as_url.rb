module LuckySneaks
  module ActsAsUrl
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_url(attribute, options = {})
        cattr_accessor :attribute_to_urlify
        cattr_accessor :scope_for_url
        cattr_accessor :url_attribute # The attribute on the DB
        
        before_validation :ensure_unique_url

        self.attribute_to_urlify = attribute
        self.scope_for_url = options[:scope]
        self.url_attribute = options[:url_attribute] || "url"
      end
    end
      
  private
    def ensure_unique_url
      url_attribute = self.class.url_attribute
      base_url = self.send(self.class.attribute_to_urlify).to_s.to_url
      conditions = ["#{url_attribute} like ?", "#{base_url}%"]
      unless new_record?
        conditions.first << " and id != ?"
        conditions << id
      end
      if self.class.scope_for_url
        conditions.first << " and #{self.class.scope_for_url} = ?"
        conditions << send(self.class.scope_for_url)
      end
      url_owners = self.class.find(:all, :conditions => conditions)
      if url_owners.size > 0
        n = 1
        while url_owners.detect{|u| u.send(url_attribute) == "#{base_url}-#{n}"}
          n = n.succ
        end
        write_attribute url_attribute, "#{base_url}-#{n}"
      else
        write_attribute url_attribute, base_url
      end
    end
  end
end