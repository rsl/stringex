# encoding: UTF-8
require 'stringex/string_extensions'
require 'stringex/unidecoder'

String.send :include, Stringex::StringExtensions

if defined?(ActiveRecord) || defined?(Mongoid)
  require 'stringex/acts_as_url' 
end

if defined?(ActiveRecord)
  ActiveRecord::Base.send :include, Stringex::ActsAsUrl
end 

if defined?(Mongoid)
  Mongoid::Document.send :include, Stringex::ActsAsUrl
end 
