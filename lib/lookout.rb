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

    def importmap
      Importmap::Map.new.draw do
        pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
        pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
        pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
        pin "application", to: "lookout/application.js", preload: true
        pin "chartkick", to: "chartkick.js"
        pin "Chart.bundle", to: "Chart.bundle.js"
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
