require 'lucky_sneaks/acts_as_url'
require 'lucky_sneaks/string_extensions'
require 'lucky_sneaks/unidecoder'

String.send :include, LuckySneaks::StringExtensions

ActiveRecord::Base.send :include, LuckySneaks::ActsAsUrl
