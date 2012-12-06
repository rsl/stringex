require 'rubygems'
gem 'activerecord'
require 'active_record'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__))

require "stringex"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "acts_as_url.sqlite3")

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :documents, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :updatuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :mocuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :permuments, :force => true do |t|
    t.string :title, :permalink, :other
  end

  create_table :procuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :blankuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :duplicatuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :validatuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :ununiquments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :limituments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :skipuments, :force => true do |t|
    t.string :title, :url, :other
  end
end
ActiveRecord::Migration.verbose = true

BASE_CLASS = ActiveRecord::Base
require File.join(File.expand_path(File.dirname(__FILE__)), '../example_classes.rb')
