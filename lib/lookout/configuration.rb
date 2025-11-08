require 'lookout/period_collection'
require 'lookout/filters_configuration'

module Lookout
  class Configuration
    attr_accessor :view_name, :theme, :realtime_interval, :disabled_widgets, :return_path, :return_copy
    attr_reader :goals, :funnels, :cache, :ranges, :event, :models, :filters, :predicate_labels
    def initialize
      @goals = GoalCollection.new
      @funnels = FunnelCollection.new
      @theme = "dark"
      @return_path = "/"
      @return_copy = "← Back"
      @ranges = ::Lookout::PeriodCollection.load_default
      @cache = ActiveSupport::OrderedOptions.new.tap do |option|
        option.enabled = false
        option.store = Rails.cache
        option.ttl = 1.minute
      end
      @models = ActiveSupport::OrderedOptions.new.tap do |option|
        option.event = "::Ahoy::Event"
        option.visit = "::Ahoy::Visit"
      end
      @event = ActiveSupport::OrderedOptions.new.tap do |option|
        option.view_name = "$view"
        # Dynamically generate SQL based on database adapter
        table_name = @models.event.parameterize.tableize
        option.url_column = DatabaseAdapter.build_url_column(table_name)
        option.url_exists = DatabaseAdapter.build_url_exists(table_name)
      end
      @filters = FiltersConfiguration.load_default
      @predicate_labels = {
        eq: 'equals',
        not_eq: 'not equals',
        cont: 'contains',
        in: 'in',
        not_in: 'not in',
      }

      @realtime_interval = 30.seconds
      @disabled_widgets = []
    end

    def goal(id, &block)
      instance = Goal.new
      instance.id = id
      instance.instance_exec(&block)
      @goals.register(instance)
    end

    def funnel(id, &block)
      instance = Funnel.new
      instance.id = id
      instance.instance_exec(&block)
      @funnels.register(instance)
    end
  end
end
