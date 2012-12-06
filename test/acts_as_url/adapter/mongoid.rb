require 'rubygems'
gem 'mongoid'
require 'mongoid'
require 'stringex'

puts "-------------------------------------------------"
puts "Running ActsAsUrl tests with Mongoid adapter"
puts "-------------------------------------------------"

Mongoid.configure do |config|
  config.connect_to('acts_as_url')
end

class Document
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self

  acts_as_url :title
end

class Updatument
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self

  acts_as_url :title, :sync_url => true
end

class Mocument
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self

  acts_as_url :title, :scope => :other, :sync_url => true
end

class Permument
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self

  acts_as_url :title, :url_attribute => :permalink
end

class Procument
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self

  acts_as_url :non_attribute_method

  def non_attribute_method
    "#{title} got massaged"
  end
end

class Blankument
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self

  acts_as_url :title, :only_when_blank => true
end

class Duplicatument
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self

  acts_as_url :title, :duplicate_count_separator => "---"
end

class Validatument
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self

  acts_as_url :title, :sync_url => true
  validates_presence_of :title
end

class Ununiqument
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self

  acts_as_url :title, :allow_duplicates => true
end

class Limitument
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self

  acts_as_url :title, :limit => 13
end

class Skipument
  include Mongoid::Document
  Stringex::ActsAsUrl.mix_into self
  acts_as_url :title, :exclude => ["_So_Fucking_Special"]
end