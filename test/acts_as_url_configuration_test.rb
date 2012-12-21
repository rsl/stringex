# encoding: UTF-8
require 'test_helper'
require 'stringex'

class ActsAsUrlConfigurationTest < Test::Unit::TestCase
  def test_can_set_base_settings
    default_configuration = Stringex::Configuration::ActsAsUrl.new(:url_attribute => "original")
    assert_equal "original", default_configuration.settings.url_attribute

    Stringex::ActsAsUrl.configure do |c|
      c.url_attribute = "special"
    end
    new_configuration = Stringex::Configuration::ActsAsUrl.new
    assert_equal "special", new_configuration.settings.url_attribute
  end

  def test_local_options_overrides_system_wide_configuration
    Stringex::ActsAsUrl.configure do |c|
      c.url_attribute = "special"
    end
    system_configuration = Stringex::Configuration::ActsAsUrl.new
    assert_equal "special", system_configuration.settings.url_attribute

    local_configuration = Stringex::Configuration::ActsAsUrl.new(:url_attribute => "local")
    assert_equal "local", local_configuration.settings.url_attribute
  end
end