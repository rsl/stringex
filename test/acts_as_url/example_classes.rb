class Document < BASE_CLASS
  acts_as_url :title
end

class Updatument < BASE_CLASS
  acts_as_url :title, :sync_url => true
end

class Mocument < BASE_CLASS
  acts_as_url :title, :scope => :other, :sync_url => true
end

class Permument < BASE_CLASS
  acts_as_url :title, :url_attribute => :permalink
end

class Procument < BASE_CLASS
  acts_as_url :non_attribute_method

  def non_attribute_method
    "#{title} got massaged"
  end
end

class Blankument < BASE_CLASS
  acts_as_url :title, :only_when_blank => true
end

class Duplicatument < BASE_CLASS
  acts_as_url :title, :duplicate_count_separator => "---"
end

class Validatument < BASE_CLASS
  acts_as_url :title, :sync_url => true
  validates_presence_of :title
end

class Ununiqument < BASE_CLASS
  acts_as_url :title, :allow_duplicates => true
end

class Limitument < BASE_CLASS
  acts_as_url :title, :limit => 13
end

class Skipument < BASE_CLASS
  acts_as_url :title, :exclude => ["_So_Fucking_Special"]
end
