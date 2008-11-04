Gem::Specification.new do |s|
  s.name     = "stringex"
  s.version  = "0.9.0"
  s.date     = "2008-10-04"
  s.summary  = "Some [hopefully] useful extensions to Ruby’s String class"
  s.email    = "rsl@luckysneaks.com"
  s.homepage = "http://github.com/rsl/stringex"
  s.description = "Some [hopefully] useful extensions to Ruby’s String class. Stringex is made up of three libraries: ActsAsUrl [permalink solution with better character translation], Unidecoder [Unicode to Ascii transliteration], and StringExtensions [miscellaneous helper methods for the String class]."
  s.has_rdoc = true
  s.authors  = "Russell Norris"
  s.files    = %w{
    init.rb
    MIT-LICENSE
    Rakefile
    README.rdoc
    stringex.gemspec
    lib/lucky_sneaks/acts_as_url.rb
    lib/lucky_sneaks/string_extensions.rb
    lib/lucky_sneaks/unidecoder.rb
  }
  s.files << Dir["lib/lucky_sneaks/unidecoder_data/*.yml"]
  s.test_files = %w{
    test/acts_as_url.sqlite3
    test/acts_as_url_test.rb
    test/string_extensions_test.rb
    test/unidecoder_test.rb
  }
  s.rdoc_options = %w{--main README.rdoc --line-numbers}
end