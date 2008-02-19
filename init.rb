String.send :include, LuckySneaks::Unidecoder
String.send :include, LuckySneaks::StringExtensions

ActiveRecord::Base.send :include, LuckySneaks::ActsAsUrl
