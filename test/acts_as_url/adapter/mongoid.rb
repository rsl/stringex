require 'rubygems'
gem 'mongoid'
require 'mongoid'
require 'stringex'
# Reload adapters to make sure ActsAsUrl sees the ORM
Stringex::ActsAsUrl::Adapter.load_available

puts "-------------------------------------------------"
puts "Running ActsAsUrl tests with Mongoid adapter"
puts "-------------------------------------------------"

Mongoid.configure do |config|
  config.connect_to('acts_as_url')
end

class Document
  include Mongoid::Document
  field :title, :type => String
  field :other, :type => String
  field :url,   :type => String

  acts_as_url :title
end

module AdapterSpecificTestBehaviors
  def setup
    # No setup tasks at present
  end

  def teardown
    Document.delete_all
    # Reset behavior to default
    Document.class_eval do
      acts_as_url :title
    end
  end

  def add_validation_on_document_title
    Document.class_eval do
      validates_presence_of :title
    end
  end

  def remove_validation_on_document_title
    Document.class_eval do
      _validators.delete :title
    end
  end
end
