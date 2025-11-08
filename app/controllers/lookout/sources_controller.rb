module Lookout
  class SourcesController < ApplicationController
    include Limitable

    before_action do
      if Widget.disabled?(:sources)
        raise Widget::WidgetDisabled.new("Widget disabled", :sources)
      end
    end

    def index
      results = cached(:sources) do
        SourceQuery.call(params)
                   .limit(limit)
      end

      @sources = paginate(results).map { |source| Lookout::SourceDecorator.new(source, self) }
    end
  end

end
