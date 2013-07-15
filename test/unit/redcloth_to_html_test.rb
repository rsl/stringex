require 'test_helper'
require 'stringex'

begin
  require 'rubygems'
  require 'RedCloth'
rescue LoadError
  puts
  puts ">> Could not load RedCloth. String#to_html was not tested."
  puts ">> Please gem install RedCloth if you'd like to use this functionality."
  puts
end

class RedclothToHTMLTest < Test::Unit::TestCase
  if defined?(RedCloth)
    def test_to_html
      {
        "h1. A Solution" => "<h1>A Solution</h1>",
        "I hated wrapping textilize around a string.\n\nIt always felt dirty." =>
          "<p>I hated wrapping textilize around a string.</p>\n<p>It always felt dirty.</p>",
        "I think _this_ is awesome" => "<p>I think <em>this</em> is awesome</p>",
        "Um... _*really*_, man" => "<p>Um&#8230; <em><strong>really</strong></em>, man</p>"
      }.each do |plain, html|
        assert_equal html, plain.to_html
      end
    end

    def test_to_html_lite
      {
        "I have no pee on me" => "I have no pee on me",
        "But I _do_ get Textile!" => "But I <em>do</em> get Textile!"
      }.each do |plain, html|
        assert_equal html, plain.to_html(:lite)
      end
    end
  end
end
