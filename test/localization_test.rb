require "test_helper"

class LocalizationTest < Test::Unit::TestCase
  def setup
    Stringex::Localization.reset!
  end

  def test_stores_translations
    Stringex::Localization.backend = :internal

    data = { :one => "number one", :two => "number two" }
    Stringex::Localization.store_translations :en, :test_store, data

    data.each do |key, value|
      assert_equal value, Stringex::Localization.translations[:en][:test_store][key]
    end
  end

  def test_converts_translation_keys_to_symbols
    Stringex::Localization.backend = :internal

    data = { "one" => "number one", "two" => "number two" }
    Stringex::Localization.store_translations :en, :test_convert, data

    data.each do |key, value|
      assert_equal value, Stringex::Localization.translations[:en][:test_convert][key.to_sym]
    end
  end

  def test_can_translate
    Stringex::Localization.backend = :internal

    data = { :one => "number one", :two => "number two" }
    Stringex::Localization.store_translations :en, :test_translate, data

    data.each do |key, value|
      assert_equal value, Stringex::Localization.translate(:test_translate, key)
    end
  end

  def test_can_translate_when_given_string_as_key
    Stringex::Localization.backend = :internal

    data = { :one => "number one", :two => "number two" }
    Stringex::Localization.store_translations :en, :test_translate, data

    data.each do |key, value|
      assert_equal value, Stringex::Localization.translate(:test_translate, key.to_s)
    end
  end

  def test_returns_default_if_none_found
    Stringex::Localization.backend = :internal
    assert_equal "my default", Stringex::Localization.translate(:test_default, :nonexistent, :default => "my default")
  end

  def test_returns_nil_if_no_default
    Stringex::Localization.backend = :internal
    assert_nil Stringex::Localization.translate(:test_no_default, :nonexistent)
  end

  def test_falls_back_to_default_locale
    Stringex::Localization.backend = :internal
    Stringex::Localization.default_locale = :es
    Stringex::Localization.locale = :da

    data = { "one" => "number one", "two" => "number two" }
    Stringex::Localization.store_translations :es, :test_default_locale, data

    data.each do |key, value|
      assert_equal value, Stringex::Localization.translate(:test_default_locale, key)
    end
  end

  def test_stores_translations_in_i18n
    Stringex::Localization.backend = :i18n

    data = { :one => "number one", :two => "number two" }
    Stringex::Localization.store_translations :en, :test_i18n_store, data

    data.each do |key, value|
      assert_equal value, I18n.translate("stringex.test_i18n_store.#{key}")
    end
  end

  def test_can_translate_using_i18n
    Stringex::Localization.backend = :i18n

    data = { :one => "number one", :two => "number two" }

    I18n.backend.store_translations :en, { :stringex => { :test_i18n_translation => data } }

    data.each do |key, value|
      assert_equal value, Stringex::Localization.translate(:test_i18n_translation, key)
    end
  end
end
