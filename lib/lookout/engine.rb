require 'ahoy'
require 'turbo-rails'
require 'stimulus-rails'
require 'ransack'
require 'view_component'
require 'chartkick'
require 'groupdate'
require 'pagy'
require 'zip'

module Ransack
  module Nodes
    class Condition

      # allows for sql from a formatter
      # see https://github.com/activerecord-hackery/ransack/issues/702
      def casted_array?(predicate)
        return unless predicate.is_a?(Arel::Nodes::Casted)

        predicate.value.is_a?(Array)
      end

    end
  end
end

Ransack.configure do |config|
  config.add_predicate 'json_cont', arel_predicate: 'contains', formatter: proc { |v| JSON.parse(v) }
  config.add_predicate 'json_eq', arel_predicate: 'eq', formatter: proc { |v| JSON.parse(v) }
end

module Lookout
  class Engine < Rails::Engine
    isolate_namespace ::Lookout

    initializer "lookout.precompile" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << Lookout::Engine.root.join("app/javascript")
        app.config.assets.paths << Lookout::Engine.root.join("app/images")
        app.config.assets.precompile << "lookout/application.js"
      end
    end

    ActiveSupport.on_load(:active_record) do
      require "lookout/active_record"
    end
  end
end
