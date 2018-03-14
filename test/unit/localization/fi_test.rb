# encoding: UTF-8

require 'test_helper'
require 'i18n'
require 'stringex'

class FinnishYAMLLocalizationTest < Test::Unit::TestCase
  def setup
    Stringex::Localization.reset!
    Stringex::Localization.backend = :i18n
    Stringex::Localization.backend.load_translations :fi
    Stringex::Localization.locale = :fi
  end

  {
    "foo & bar" => "foo ja bar",
    "AT&T" => "AT ja T",
    "99° is normal" => "99 astetta is normal",
    "4 ÷ 2 is 2" => "4 jaettuna luvulla 2 is 2",
    "webcrawler.com" => "webcrawler piste com",
    "Well..." => "Well piste piste piste",
    "x=1" => "x on yhtä kuin 1",
    "a #2 pencil" => "a numero 2 pencil",
    "100%" => "100 prosenttia",
    "cost+tax" => "cost plus tax",
    "batman/robin fan fiction" => "batman kautta robin fan fiction",
    "dial *69" => "dial tahti 69",
    " i leave whitespace on ends unchanged " => " i leave whitespace on ends unchanged "
  }.each do |original, converted|
    define_method "test_character_conversion: '#{original}'" do
      assert_equal converted, original.convert_miscellaneous_characters
    end
  end

  {
    "¤20" => "20 puntaa",
    "$100" => "100 dollaria",
    "$19.99" => "19 dollaria 99 senttiä",
    "£100" => "100 puntaa",
    "£19.99" => "19 puntaa 99 pennyä",
    "€100" => "100 euroa",
    "€19.99" => "19 euroa 99 senttiä",
    "¥1000" => "1000 yenia"
  }.each do |original, converted|
    define_method "test_currency_conversion: '#{original}'" do
      assert_equal converted, original.convert_miscellaneous_characters
    end
  end

  {
    "Tea &amp; Sympathy" => "Tea ja Sympathy",
    "10&cent;" => "10 senttiä",
    "&copy;2000" => "(c)2000",
    "98&deg; is fine" => "98 astetta is fine",
    "10&divide;5" => "10 jaettuna luvulla 5",
    "&quot;quoted&quot;" => '"quoted"',
    "to be continued&hellip;" => "to be continued...",
    "2000&ndash;2004" => "2000-2004",
    "I wish&mdash;oh, never mind" => "I wish--oh, never mind",
    "&frac12; ounce of gold" => "puoli ounce of gold",
    "1 and &frac14; ounces of silver" => "1 and yksi neljäsosa ounces of silver",
    "9 and &frac34; ounces of platinum" => "9 and kolme neljäsosaa ounces of platinum",
    "3&gt;2" => "3>2",
    "2&lt;3" => "2<3",
    "two&nbsp;words" => "two words",
    "&pound;100" => "punta 100",
    "Walmart&reg;" => "Walmart(r)",
    "&apos;single quoted&apos;" => "'single quoted'",
    "2&times;4" => "2x4",
    "Programming&trade;" => "Programming(tm)",
    "&yen;20000" => "yen 20000",
    " i leave whitespace on ends unchanged " => " i leave whitespace on ends unchanged "
  }.each do |original, converted|
    define_method "test_html_entity_conversion: '#{original}'" do
      assert_equal converted, original.convert_miscellaneous_html_entities
    end
  end

  {
    "&frac12;" => "puoli",
    "½" => "puoli",
    "&#189;" => "puoli",
    "⅓" => "yksi kolmaosa",
    "&#8531;" => "yksi kolmaosa",
    "⅔" => "kaksi kolmasosaa",
    "&#8532;" => "kaksi kolmasosaa",
    "&frac14;" => "yksi neljäsosa",
    "¼" => "yksi neljäsosa",
    "&#188;" => "yksi neljäsosa",
    "&frac34;" => "kolme neljäsosaa",
    "¾" => "kolme neljäsosaa",
    "&#190;" => "kolme neljäsosaa",
    "⅕" => "yksi viidesosa",
    "&#8533;" => "yksi viidesosa",
    "⅖" => "kaksi viidesosaa",
    "&#8534;" => "kaksi viidesosaa",
    "⅗" => "kolme viidesosaa",
    "&#8535;" => "kolme viidesosaa",
    "⅘" => "nelja viidesosaa",
    "&#8536;" => "nelja viidesosaa",
    "⅙" => "yksi kuudesosa",
    "&#8537;" => "yksi kuudesosa",
    "⅚" => "viisi kuudesosaa",
    "&#8538;" => "viisi kuudesosaa",
    "⅛" => "yksi kahdeksasosa",
    "&#8539;" => "yksi kahdeksasosa",
    "⅜" => "kolme kahdeksasosaa",
    "&#8540;" => "kolme kahdeksasosaa",
    "⅝" => "viisi kahdeksasosaa",
    "&#8541;" => "viisi kahdeksasosaa",
    "⅞" => "seitsemän kahdeksasosaa",
    "&#8542;" => "seitsemän kahdeksasosaa"
  }.each do |original, converted|
    define_method "test_vulgar_fractions_conversion: #{original}" do
      assert_equal converted, original.convert_vulgar_fractions
    end
  end
end
