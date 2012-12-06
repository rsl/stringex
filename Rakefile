# coding: utf-8

require 'rake'
require 'rake/testtask'
require 'rdoc/task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name             = "stringex"
    gem.authors          = ["Russell Norris"]
    gem.email            = "rsl@luckysneaks.com"
    gem.homepage         = "http://github.com/rsl/stringex"
    gem.summary          = "Some [hopefully] useful extensions to Ruby's String class"
    gem.description      = "Some [hopefully] useful extensions to Ruby's String class. Stringex is made up of three libraries: ActsAsUrl [permalink solution with better character translation], Unidecoder [Unicode to ASCII transliteration], and StringExtensions [miscellaneous helper methods for the String class]."
    gem.files.exclude '.travis.yml'
    gem.has_rdoc         = true
    gem.rdoc_options     = %w{--main README.rdoc --charset utf-8 --line-numbers}
    gem.extra_rdoc_files =  %w{MIT-LICENSE README.rdoc}
  end

  Jeweler::RubygemsDotOrgTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.pattern   = 'test/**/*_test.rb'
  t.verbose   = true
end

desc 'Default: Run Stringex test suite using ActiveRecord as the ORM'
task :default => [:setup_active_record_suite, :test]

task :setup_active_record_suite do
  `rm -f #{File.dirname(__FILE__)}/test/acts_as_url.sqlite3`
  ENV['ADAPTER'] = 'active_record'
end

desc 'Run Stringex test suite using ActiveRecord as the ORM'
namespace :test do
  task :active_record => [:setup_active_record_suite, :test]
end

task :setup_mongoid_suite do
  ENV['ADAPTER'] = 'mongoid'
end

desc 'Run Stringex test suite using Mongoid as the ORM'
namespace :test do
  task :mongoid => [:setup_mongoid_suite, :test]
end

desc 'Generate RDoc for Stringex'
Rake::RDocTask.new(:rdoc) do |rdoc|
  version       = File.read('VERSION')
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "Stringex: A String Extension Pack [Version #{version}]"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
