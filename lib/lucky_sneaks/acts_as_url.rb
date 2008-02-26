module LuckySneaks
  module ActsAsUrl
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_url(attribute, options = {})
        cattr_accessor :attribute_for_url
        cattr_accessor :scope_for_url
        
        before_validation :ensure_unique_url

        self.attribute_for_url = attribute
        self.scope_for_url = options[:scope]
      end
    end
      
  private
    def ensure_unique_url
      base_url = self.send(self.class.attribute_for_url).to_s.to_url
      conditions = ["url like ?", "#{base_url}%"]
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
        while url_owners.detect{|u| u.url == "#{base_url}-#{n}"}
          n = n.succ
        end
        self.url = "#{base_url}-#{n}"
      else
        self.url = base_url
      end
    end
  end
end