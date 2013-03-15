module Stringex
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer "stringex" do |app|
      locales = app.config.i18n.available_locales
      pattern = locales.blank? ? "*" : "{#{locales.join(',')}}"
      files = Dir[File.join(File.dirname(__FILE__), "..", "..", "..", "locales", "#{pattern}.yml")]
      I18n.load_path.concat(files)
    end
  end
end