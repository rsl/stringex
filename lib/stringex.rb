# encoding: UTF-8
require 'stringex/string_extensions'
require 'stringex/unidecoder'

String.send :include, Stringex::StringExtensions

if defined?(ActiveRecord)
  require 'stringex/acts_as_url'
  ActiveRecord::Base.send :include, Stringex::ActsAsUrl
end
