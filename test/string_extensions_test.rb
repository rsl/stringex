# encoding: UTF-8

require "test_helper"
require "stringex"

if RUBY_VERSION.to_f < 1.9
  $KCODE = "U"
end

class StringExtensionsTest < Test::Unit::TestCase
  def setup
    Stringex::Localization.reset!
  end

  def test_to_url
    {
      "<p>This has 100% too much    <em>formatting</em></p>" =>
        "this-has-100-percent-too-much-formatting",
      "Tea   &amp; crumpets &amp; <strong>cr&ecirc;pes</strong> for me!" =>
        "tea-and-crumpets-and-crepes-for-me",
      "The Suspense... Is... Killing Me" =>
        "the-suspense-dot-dot-dot-is-dot-dot-dot-killing-me",
      "How to use attr_accessible and attr_protected" =>
        "how-to-use-attr-accessible-and-attr-protected",
      "I'm just making sure there's nothing wrong with things!" =>
        "im-just-making-sure-theres-nothing-wrong-with-things",
      "foo = bar and bar=foo" =>
        "foo-equals-bar-and-bar-equals-foo",
      "Period.period" =>
        "period-dot-period",
      "Will…This Work?" =>
        "will-dot-dot-dot-this-work",
      "We check the D.N.A for matches" =>
        "we-check-the-dna-for-matches",
      "We check the D.N.A. for matches" =>
        "we-check-the-dna-for-matches",
      "Go to the Y.M.C.America" =>
        "go-to-the-ymcamerica",
      "He shops at J.C. Penney" =>
        "he-shops-at-jc-penney",
      "¼ pound with cheese" =>
        "one-fourth-pound-with-cheese",
      "Will's Ferrel" =>
        "wills-ferrel",
      "Капитал" =>
        "kapital",
      "Ελλάδα" =>
        "ellada",
      "中文" =>
        "zhong-wen",
      "Paul Cézanne" =>
        "paul-cezanne",
      "21'17ʼ51" =>
        "21-17-51",
      "ITCZ÷1 (21°17ʼ51.78”N / 89°35ʼ28.18”O / 26-04-08 / 09:00 am)" =>
        "itcz-divided-by-1-21-degrees-17-51-dot-78-n-slash-89-degrees-35-28-dot-18-o-slash-26-04-08-slash-09-00-am",
      "／" =>
        "slash",
      "私はガラスを食べられます。それは私を傷つけません。" =>
        "si-hagarasuwoshi-beraremasu-sorehasi-woshang-tukemasen",
      "ǝ is a magical string" =>
        "at-is-a-magical-string",
      "either | or" =>
        "either-or",
      "La Maison d`Uliva" =>
        "la-maison-duliva",
      "カッページ・テラスに日系カフェ＆バー、店内にDJブースも - シンガポール経済新聞" =>
        "katupeziterasuniri-xi-kahue-and-ba-dian-nei-nidjbusumo-singaporujing-ji-xin-wen",
      "AVアンプ、ホームシアターシステム、スピーカーシステム等" =>
        "avanpu-homusiatasisutemu-supikasisutemudeng",
      "У лукоморья дуб зеленый" =>
        "u-lukomoria-dub-zielienyi",
      "Here are some {braces}" =>
        "here-are-some-braces"
    }.each do |html, plain|
      assert_equal plain, html.to_url
    end
  end

  def test_to_url_with_excludes
    assert_equal "So Fucking Special", "So Fucking Special".to_url(:exclude => "So Fucking Special")
  end

  def test_to_url_without_forcing_downcase
    assert_equal "I-have-CAPS", "I have CAPS".to_url(:force_downcase => false)
  end

  def test_to_url_with_limit
    assert_equal "I am much too long".to_url(:limit => 13), "i-am-much-too"
  end

  def test_to_url_with_alternate_whitespace_replacement
    assert_equal "under_scores", "Under Scores".to_url(:replace_whitespace_with => "_")
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

  def test_convert_accented_html_entities
    {
      "&aring;"  => "a",
      "&egrave;" => "e",
      "&icirc;"  => "i",
      "&Oslash;" => "O",
      "&uuml;"   => "u",
      "&Ntilde;" => "N",
      "&ccedil;" => "c"
    }.each do |entitied, plain|
      assert_equal plain, entitied.convert_accented_html_entities
    end
  end

  def test_localized_vulgar_fractions_conversion
    Stringex::Localization.backend = :internal
    Stringex::Localization.store_translations :de, :vulgar_fractions, {
      :one_fourth => "en fjerdedel",
      :half => "en halv"
    }
    Stringex::Localization.locale = :de

    {
      "&frac14;" => "en fjerdedel",
      "½" => "en halv"
    }.each do |entitied, plain|
      assert_equal plain, entitied.convert_vulgar_fractions
    end
  end

  def test_localized_html_entities_conversion
    Stringex::Localization.backend = :internal
    Stringex::Localization.store_translations :de, :html_entities, {
      :amp => "und",
      :ellipsis => " prik prik prik",
      :frac14 => "en fjerdedel"
    }
    Stringex::Localization.locale = :de

    {
      "Tea &amp; Sympathy" => "Tea und Sympathy",
      "To be continued&#8230;" => "To be continued prik prik prik",
      "Det var til &frac14; af prisen" => "Det var til en fjerdedel af prisen"
    }.each do |entitied, plain|
      assert_equal plain, entitied.convert_miscellaneous_html_entities
    end
  end

  def test_convert_smart_punctuation
    {
      "“smart quotes”" => '"smart quotes"',
      "‘dumb quotes’" => "'dumb quotes'",
      "I love you, but…" => "I love you, but...",
    }.each do |smart, plain|
      assert_equal plain, smart.convert_smart_punctuation
    end
  end

  def test_localized_character_conversions
    Stringex::Localization.backend = :internal
    Stringex::Localization.store_translations :de, :characters, {
      "and" => "und",
      :percent => "procent"
    }
    Stringex::Localization.locale = :de

    {
      "ich & dich" => "ich und dich",
      "det var 100% godt" => "det var 100 procent godt"
    }.each do |misc, plain|
      assert_equal plain, misc.convert_miscellaneous_characters
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
