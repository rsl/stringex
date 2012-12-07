# encoding: UTF-8
require 'test_helper'

adapter = ENV['ADAPTER'] || 'active_record'
require File.join(File.expand_path(File.dirname(__FILE__)), "acts_as_url/adapter/#{adapter}.rb")

class ActsAsUrlTest < Test::Unit::TestCase
  include AdapterSpecificTestBehaviors

  def test_should_create_url
    @doc = Document.create(:title => "Let's Make a Test Title, <em>Okay</em>?")
    assert_equal "lets-make-a-test-title-okay", @doc.url
  end

  def test_should_create_unique_url
    @doc = Document.create!(:title => "Unique")
    @other_doc = Document.create!(:title => "Unique")
    assert_equal "unique-1", @other_doc.url
  end

  def test_should_not_create_unique_url
    @doc = Ununiqument.create!(:title => "I am not a clone")
    @other_doc = Ununiqument.create!(:title => "I am not a clone")
    assert_equal "i-am-not-a-clone", @other_doc.url
  end

  def test_should_not_succ_on_repeated_saves
    @doc = Document.new(:title => "Continuous or Constant")
    5.times do
      @doc.save!
      assert_equal "continuous-or-constant", @doc.url
    end
  end

  def test_should_create_unique_url_and_not_clobber_if_another_exists
    @doc = Updatument.create!(:title => "Unique")
    @other_doc = Updatument.create!(:title => "Unique")
    @doc.update_attributes :other => "foo"

    @doc2 = Document.create!(:title => "twonique")
    @other_doc2 = Document.create!(:title => "twonique")
    @doc2.update_attributes(:other => "foo")

    assert_equal "unique", @doc.url
    assert_equal "foo", @doc.other
    assert_equal "unique-1", @other_doc.url

    assert_equal "twonique", @doc2.url
    assert_equal "foo", @doc2.other
    assert_equal "twonique-1", @other_doc2.url
  end

  def test_should_create_unique_url_when_partial_url_already_exists
    @doc = Document.create!(:title => "House Farms")
    @other_doc = Document.create!(:title => "House Farm")

    assert_equal "house-farms", @doc.url
    assert_equal "house-farm", @other_doc.url
  end

  def test_should_scope_uniqueness
    @moc = Mocument.create!(:title => "Mocumentary", :other => "I dunno why but I don't care if I'm unique")
    @other_moc = Mocument.create!(:title => "Mocumentary")
    assert_equal @moc.url, @other_moc.url
  end

  def test_should_still_create_unique_if_in_same_scope
    @moc = Mocument.create!(:title => "Mocumentary", :other => "Suddenly, I care if I'm unique")
    @other_moc = Mocument.create!(:title => "Mocumentary", :other => "Suddenly, I care if I'm unique")
    assert_not_equal @moc.url, @other_moc.url
  end

  def test_should_use_alternate_field_name
    @perm = Permument.create!(:title => "Anything at This Point")
    assert_equal "anything-at-this-point", @perm.permalink
  end

  def test_should_not_update_url_by_default
    @doc = Document.create!(:title => "Stable as Stone")
    @original_url = @doc.url
    @doc.update_attributes :title => "New Unstable Madness"
    assert_equal @original_url, @doc.url
  end

  def test_should_update_url_if_asked
    @moc = Mocument.create!(:title => "Original")
    @original_url = @moc.url
    @moc.update_attributes :title => "New and Improved"
    assert_not_equal @original_url, @moc.url
  end

  def test_should_update_url_only_when_blank_if_asked
    @original_url = 'the-url-of-concrete'
    @blank = Blankument.create!(:title => "Stable as Stone", :url => @original_url)
    assert_equal @original_url, @blank.url
    @blank = Blankument.create!(:title => "Stable as Stone")
    assert_equal 'stable-as-stone', @blank.url
  end

  def test_should_mass_initialize_urls
    @doc_1 = Document.create!(:title => "Initial")
    @doc_2 = Document.create!(:title => "Subsequent")
    @doc_1.update_attribute :url, nil
    @doc_2.update_attribute :url, nil
    assert_nil @doc_1.url
    assert_nil @doc_2.url
    Document.initialize_urls
    @doc_1.reload
    @doc_2.reload
    assert_equal "initial", @doc_1.url
    assert_equal "subsequent", @doc_2.url
  end

  def test_should_mass_initialize_urls_with_custom_url_attribute
    @doc_1 = Permument.create!(:title => "Initial")
    @doc_2 = Permument.create!(:title => "Subsequent")
    @doc_1.update_attribute :permalink, nil
    @doc_2.update_attribute :permalink, nil
    assert_nil @doc_1.permalink
    assert_nil @doc_2.permalink
    Permument.initialize_urls
    @doc_1.reload
    @doc_2.reload
    assert_equal "initial", @doc_1.permalink
    assert_equal "subsequent", @doc_2.permalink
  end

  def test_should_utilize_block_if_given
    @doc = Procument.create!(:title => "Title String")
    assert_equal "title-string-got-massaged", @doc.url
  end

  def test_should_create_unique_with_custom_duplicate_count_separator
    @doc = Duplicatument.create!(:title => "Unique")
    @other_doc = Duplicatument.create!(:title => "Unique")
    assert_equal "unique", @doc.url
    assert_equal "unique---1", @other_doc.url
  end

  def test_should_only_update_url_if_model_is_valid
    @doc = Validatument.create!(:title => "Initial")
    @doc.title = nil
    assert !@doc.valid?
    assert_equal "initial", @doc.url
  end

  def test_should_allow_url_limit
    @doc = Limitument.create!(:title => "I am much too long")
    assert_equal "i-am-much-too", @doc.url
  end

  def test_should_handle_duplicate_urls_with_limits
    @doc = Limitument.create!(:title => "I am long but not unique")
    assert_equal "i-am-long-but", @doc.url
    @doc_2 = Limitument.create!(:title => "I am long but not unique")
    assert_equal "i-am-long-but-1", @doc_2.url
  end

  def test_should_allow_exclusions
    @doc = Skipument.create!(:title => "_So_Fucking_Special")
    assert_equal "_So_Fucking_Special", @doc.url
    @doc_2 = Skipument.create!(:title => "But I'm a creep")
    assert_equal "but-im-a-creep", @doc_2.url
  end
end
