# A sample Gemfile
source 'https://rubygems.org'

def activerecord?
  adapter.nil? || adapter == 'activerecord'
end

def datamapper?
  adapter == 'datamapper'
end

def mongoid?
  if RUBY_VERSION > '1.8.x'
    adapter == 'mongoid'
  else
    puts 'Mongoid requires Ruby higher than 1.8.x'
  end
end

def adapter
  ENV['ADAPTER']
end

group :development do
  # Standard gems across gemfiles
  gem 'jeweler', '2.0.1'
  gem 'travis-lint', '1.7.0'
  # Can I state that I really dislike camelcased gem names?
  gem 'RedCloth', '4.2.9'
  gem 'sqlite3', '1.3.7'

  if activerecord?
    gem 'activerecord', '4.0.3'
  end

  if datamapper?
    gem 'dm-core', '1.2.1'
    gem 'dm-migrations', '1.2.0'
    gem 'dm-sqlite-adapter', '1.2.0'
    gem 'dm-validations', '1.2.0'
  end

  if mongoid?
    gem 'mongoid', '3.1.6'
    gem 'i18n', '0.6.1'
  else
    # Everyone else can get the most up-to-date I18n
    gem 'i18n', '0.6.9'
  end
end
