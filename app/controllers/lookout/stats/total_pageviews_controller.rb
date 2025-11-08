module Lookout
  module Stats
    class TotalPageviewsController < BaseController
      def index
        @stats = lazy_window(Lookout::Stats::TotalPageviewsQuery.call(params).with_lazy_comparison(compare_mode?).group_by_period(selected_interval, :time).count, 0)
        @label = "Visitors"
      end
    end
  end
end
