module Stringex
  module Configuration
    class Configurator
      attr_accessor :klass

      def initialize(klass)
        @klass = klass

        self.klass.valid_configuration_details.each do |name|
          define_instance_method_for_configuration_wrapper name
        end
      end

      def define_instance_method_for_configuration_wrapper(name)
        (class << self; self; end).instance_eval do
          define_method("#{name}=") do |value|
            customizations = klass.send(:system_wide_customizations)
            customizations[name.intern] = value
          end
        end
      end
    end
  end
end