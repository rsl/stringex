require "test/unit"

TEST_ROOT = File.dirname(__FILE__)
require File.join(TEST_ROOT, "../lib/lucky_sneaks/string_extensions")

class StringExtensionsTest < Test::Unit::TestCase
  def test_to_url
    {
      "<p>This has 100% too much    <em>formatting</em></p>" =>
        "this-has-100-percent-too-much-formatting",
      "Tea   &amp; crumpets &amp; <strong>cr&ecirc;pes</strong> for me!" => 
        "tea-and-crumpets-and-crepes-for-me"
    }.each do |html, plain|
      assert_equal plain, html.to_url
    end
  end
  
  def test_remove_formatting
    {
      "<p>This has 100% too much    <em>formatting</em></p>" =>
        "This has 100 percent too much formatting",
      "Tea   &amp; crumpets &amp; <strong>cr&ecirc;pes</strong> for me!" => 
        "Tea and crumpets and crepes for me"
    }.each do |html, plain|
      assert_equal plain, html.remove_formatting
    end
  end
  
  def test_strip_html_tags
    {
      "<h1><em>This</em> is good but <strong>that</strong> is better</h1>" =>
        "This is good but that is better",
      "<p>This is invalid XHTML but valid HTML, right?" =>
        "This is invalid XHTML but valid HTML, right?",
      "<p class='foo'>Everything goes!</p>" => "Everything goes!",
      "<ol>This is completely invalid and just plain wrong</p>" =>
        "This is completely invalid and just plain wrong"
    }.each do |html, plain|
      assert_equal plain, html.strip_html_tags
    end
  end
  
  def test_convert_accented_entities
    {
      "&aring;"  => "a",
      "&egrave;" => "e",
      "&icirc;"  => "i",
      "&Oslash;" => "O",
      "&uuml;"   => "u",
      "&Ntilde;" => "N",
      "&ccedil;" => "c"
    }.each do |entitied, plain|
      assert_equal plain, entitied.convert_accented_entities
    end
  end
  
  def test_convert_misc_entities
    {
      "America&#8482;" => "America(tm)",
      "Tea &amp; Sympathy" => "Tea and Sympathy",
      "To be continued&#8230;" => "To be continued...",
      "Foo&nbsp;Bar" => "Foo Bar",
      "100&#163;" => "100 pound",
      "&frac12; a dollar" => "half a dollar",
      "35&deg;" => "35 degrees"
    }.each do |entitied, plain|
      assert_equal plain, entitied.convert_misc_entities
    end
  end
  
  def test_convert_misc_characters
    {
      "Foo & bar make foobar" => "Foo and bar make foobar",
      "Breakdown #9" => "Breakdown number 9",
      "foo@bar.com" => "foo at bar dot com",
      "100% of yr love" => "100 percent of yr love"
    }.each do |misc, plain|
      assert_equal plain, misc.convert_misc_characters
    end
  end
  
  def test_replace_whitespace
    {
      "this has     too much space" => "this has too much space",
      "\t\tThis is merely formatted with superfluous whitespace\n" =>
        " This is merely formatted with superfluous whitespace "
    }.each do |whitespaced, plain|
      assert_equal plain, whitespaced.replace_whitespace
    end
    
    assert_equal "now-with-more-hyphens", "now with more hyphens".replace_whitespace("-")
  end
  
  def test_collapse
    {
      "too      much space" => "too much space",
      "  at the beginning" => "at the beginning"
    }.each do |uncollapsed, plain|
      assert_equal plain, uncollapsed.collapse
    end
    
    assert_equal "now-with-hyphens", "----now---------with-hyphens--------".collapse("-")
  end
end