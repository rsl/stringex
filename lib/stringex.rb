# encoding: UTF-8
require 'ostruct'
require 'stringex/configuration'
require 'stringex/localization'
require 'stringex/string_extensions'
require 'stringex/unidecoder'
require 'stringex/acts_as_url'

String.send :include, Stringex::StringExtensions::PublicInstanceMethods
String.send :extend, Stringex::StringExtensions::PublicClassMethods

Stringex::ActsAsUrl::Adapter.load_available

if defined?(Rails)
  require 'stringex/rails/railtie'
end