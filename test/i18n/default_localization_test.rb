# encoding: UTF-8

require 'test_helper'
require 'stringex'

class DefaultLocalizationTest < Test::Unit::TestCase
  def setup
    Stringex::Localization.reset!

    Stringex::Localization.backend = :internal
  end

  def test_convert_miscellaneous_characters
    {
      "Foo & bar make foobar" => "Foo and bar make foobar",
      "Breakdown #9" => "Breakdown number 9",
      "foo@bar.com" => "foo at bar dot com",
      "100% of yr love" => "100 percent of yr love",
      "Kisses are $3.25 each" => "Kisses are 3 dollars 25 cents each",
      "That CD is £3.25 plus tax" => "That CD is 3 pounds 25 pence plus tax",
      "This CD is ¥1000 instead" => "This CD is 1000 yen instead",
      "In Europe you can buy it for €2 or €4.10" => "In Europe you can buy it for 2 euros or 4 euros 10 cents",
      "Food+Drink" => "Food plus Drink",
      "this & that #2 @ bla.bla for $3" => "this and that number 2 at bla dot bla for 3 dollars",
      "three + four ÷ 40 ° fahrenheit... end" => "three plus four divide 40 degrees fahrenheit dot dot dot end",
      "£4 but ¥5 * 100% = two" => "4 pounds but 5 yen star 100 percent equals two"
    }.each do |misc, plain|
      assert_equal plain, misc.convert_miscellaneous_characters
    end
  end

  def test_convert_miscellaneous_html_entities
    {
      "America&#8482;" => "America(tm)",
      "Tea &amp; Sympathy" => "Tea and Sympathy",
      "To be continued&#8230;" => "To be continued...",
      "Foo&nbsp;Bar" => "Foo Bar",
      "100&#163;" => "100 pound",
      "35&deg;" => "35 degrees"
    }.each do |entitied, plain|
      assert_equal plain, entitied.convert_miscellaneous_html_entities
    end
  end

  def test_convert_vulgar_fractions
    {
      "&frac14;" => "one fourth",
      "¼" => "one fourth",
      "&#188;" => "one fourth",
      "&frac12;" => "half",
      "½" => "half",
      "&#189;" => "half",
      "&frac34;" => "three fourths",
      "¾" => "three fourths",
      "&#190;" => "three fourths",
      "⅓" => "one third",
      "&#8531;" => "one third",
      "⅔" => "two thirds",
      "&#8532;" => "two thirds",
      "⅕" => "one fifth",
      "&#8533;" => "one fifth",
      "⅖" => "two fifths",
      "&#8534;" => "two fifths",
      "⅗" => "three fifths",
      "&#8535;" => "three fifths",
      "⅘" => "four fifths",
      "&#8536;" => "four fifths",
      "⅙" => "one sixth",
      "&#8537;" => "one sixth",
      "⅚" => "five sixths",
      "&#8538;" => "five sixths",
      "⅛" => "one eighth",
      "&#8539;" => "one eighth",
      "⅜" => "three eighths",
      "&#8540;" => "three eighths",
      "⅝" => "five eighths",
      "&#8541;" => "five eighths",
      "⅞" => "seven eighths",
      "&#8542;" => "seven eighths"
    }.each do |entitied, plain|
      assert_equal plain, entitied.convert_vulgar_fractions
    end
  end
end
