require "lookout/version"
require "lookout/railtie"
require "lookout/engine"
require "lookout/goals"
require "lookout/funnels"
require "lookout/database_adapter"
require "lookout/configuration"
require "lookout/predicate_label"
require 'lookout/ahoy/visit_methods'
require 'lookout/ahoy/event_methods'

require 'importmap-rails'

module Lookout
  class << self
    attr_accessor :configuration

    def cache
      @cache ||= if config.cache[:enabled]
                   config.cache[:store]
                 else
                   ActiveSupport::Cache::NullStore.new
                 end
    end

    # Rails 8+ one-liner support:
    # In a host app's config/importmap.rb you can now do:
    #   Lookout.importmap(self)
    # This will draw all Lookout pins onto the host's map builder.
    # If no builder is provided, this returns a standalone Importmap::Map (for inlining).
    def importmap(builder = nil)
      if builder
        builder.pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
        builder.pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
        builder.pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
        builder.pin "application", to: "lookout/application.js", preload: true
        # Chart.js must be pinned BEFORE its plugins
        builder.pin "chart.js", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js", preload: true
        builder.pin "chartjs-plugin-datalabels", to: "https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2", preload: true
        builder.pin "classnames", to: "https://cdnjs.cloudflare.com/ajax/libs/classnames/2.3.2/index.min.js", preload: true
        builder.pin "chartjs-chart-geo", to: "https://cdn.jsdelivr.net/npm/chartjs-chart-geo@4.3.6/build/index.umd.min.js", preload: true
        builder.pin_all_from Lookout::Engine.root.join("app/assets/javascript/lookout/controllers"), under: "controllers", to: "lookout/controllers"
        builder.pin_all_from Lookout::Engine.root.join("app/assets/javascript/lookout/helpers"), under: "helpers", to: "lookout/helpers"
        return builder
      end

      Importmap::Map.new.draw do
        pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
        pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
        pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
        pin "application", to: "lookout/application.js", preload: true
        # Chart.js must be pinned BEFORE its plugins
        pin "chart.js", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js", preload: true
        pin "chartjs-plugin-datalabels", to: "https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2", preload: true
        pin "classnames", to: "https://cdnjs.cloudflare.com/ajax/libs/classnames/2.3.2/index.min.js", preload: true
        pin "chartjs-chart-geo", to: "https://cdn.jsdelivr.net/npm/chartjs-chart-geo@4.3.6/build/index.umd.min.js", preload: true
        pin_all_from Lookout::Engine.root.join("app/assets/javascript/lookout/controllers"), under: "controllers", to: "lookout/controllers"
        pin_all_from Lookout::Engine.root.join("app/assets/javascript/lookout/helpers"), under: "helpers", to: "lookout/helpers"
      end
    end

    def config
      self.configuration ||= Configuration.new
    end

    def configure
      yield config
    end

    def event
      @event ||= config.models[:event].constantize
    end

    def visit
      @visit ||= config.models[:visit].constantize
    end

    def none
      @none ||= OpenStruct.new(text: "(none)", value: "!none!")
    end
  end
end
