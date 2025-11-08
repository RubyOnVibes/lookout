require "rails/generators"

module Lookout
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.join(__dir__, "templates")

      def copy_templates
        insert_into_file ::Rails.root.join("app/models/ahoy/event.rb").to_s, "  include Lookout::Ahoy::EventMethods\n", after: "class Ahoy::Event < ApplicationRecord\n"
        insert_into_file ::Rails.root.join("app/models/ahoy/visit.rb").to_s, "  include Lookout::Ahoy::VisitMethods\n", after: "class Ahoy::Visit < ApplicationRecord\n"

        template "config.rb", "config/initializers/lookout.rb"

        route "mount Lookout::Engine => '/lookout'"
      end
    end
  end
end
