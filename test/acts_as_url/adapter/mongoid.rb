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