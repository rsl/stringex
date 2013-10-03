# A sample Gemfile
source "https://rubygems.org"

group :development do
  gem "activerecord", "3.2.13"
  gem "dm-core", "1.2.0"
  gem "dm-migrations", "1.2.0"
  gem "dm-sqlite-adapter", "1.2.0"
  gem "dm-validations", "1.2.0"
  gem "jeweler", "1.8.4"
  if RUBY_VERSION > "1.8.x"
    gem "mongoid", "3.1.4"
  else
    puts "Mongoid requires Ruby higher than 1.8.x"
  end
  gem "RedCloth", "4.2.9" # Can I state that I really dislike camelcased gem names?
  gem "sqlite3", "1.3.7", :platform => [:ruby, :mswin, :mingw]
  gem "jdbc-sqlite3", "3.7.2.1", :platform => :jruby
  gem "travis-lint", "1.7.0"
  gem "i18n", "0.6.1"
end
