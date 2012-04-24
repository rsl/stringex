# encoding: UTF-8
require 'test/unit'

begin
  require File.expand_path(File.dirname(__FILE__)) + '/../../../config/environment'
rescue LoadError
  require 'rubygems'
  gem 'activerecord'
  require 'active_record'

  RAILS_ROOT = File.expand_path(File.dirname(__FILE__))
  $: << File.join(File.expand_path(File.dirname(__FILE__)), '../lib')
end

require File.join(File.expand_path(File.dirname(__FILE__)), '../init.rb')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "acts_as_url.sqlite3")

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :documents, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :updateuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :mocuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :permuments, :force => true do |t|
    t.string :title, :permalink, :other
  end

  create_table :procuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :blankuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :duplicateuments, :force => true do |t|
    t.string :title, :url, :other
  end

  create_table :validatuments, :force => true do |t|
    t.string :title, :url, :other
  end
  
  create_table :ununiquments, :force => true do |t|
    t.string :title, :url, :other
  end
end
ActiveRecord::Migration.verbose = true

class Document < ActiveRecord::Base
  acts_as_url :title
end

class Updateument < ActiveRecord::Base
  acts_as_url :title, :sync_url => true
end

class Mocument < ActiveRecord::Base
  acts_as_url :title, :scope => :other, :sync_url => true
end

class Permument < ActiveRecord::Base
  acts_as_url :title, :url_attribute => :permalink
end

class Procument < ActiveRecord::Base
  acts_as_url :non_attribute_method

  def non_attribute_method
    "#{title} got massaged"
  end
end

class Blankument < ActiveRecord::Base
  acts_as_url :title, :only_when_blank => true
end

class Duplicateument < ActiveRecord::Base
  acts_as_url :title, :duplicate_count_separator => "---"
end

class Validatument < ActiveRecord::Base
  acts_as_url :title, :sync_url => true
  validates_presence_of :title
end

class Ununiqument < ActiveRecord::Base
  acts_as_url :title, :allow_duplicates => true
end

class ActsAsUrlTest < Test::Unit::TestCase
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
    @doc = Updateument.create!(:title => "Unique")
    @other_doc = Updateument.create!(:title => "Unique")
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
    @doc = Duplicateument.create!(:title => "Unique")
    @other_doc = Duplicateument.create!(:title => "Unique")
    assert_equal "unique", @doc.url
    assert_equal "unique---1", @other_doc.url
  end

  def test_should_only_update_url_if_model_is_valid
    @doc = Validatument.create!(:title => "Initial")
    @doc.title = nil
    assert !@doc.valid?
    assert_equal "initial", @doc.url
  end
end
