module Lookout
  module Stats
    class UniqueVisitorsController < BaseController
      def index
        @stats = Lookout::Stats::UniqueVisitorsQuery.call(params).with_lazy_comparison(compare_mode?).group_by_period(selected_interval, :started_at).count
        @stats = lazy_window(@stats)
        @label = "Visitors"
      end
    end
  end
end
