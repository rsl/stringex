# encoding: UTF-8
require 'stringex/string_extensions'
require 'stringex/unidecoder'

String.send :include, Stringex::StringExtensions::PublicInstanceMethods
String.send :extend, Stringex::StringExtensions::PublicClassMethods

require 'stringex/acts_as_url' if defined?(ActiveRecord) || defined?(Mongoid::Document)

ActiveRecord::Base.send :include, Stringex::ActsAsUrl if defined?(ActiveRecord)
