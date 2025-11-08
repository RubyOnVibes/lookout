module Lookout
  module Stats
    class VisitDurationQuery < BaseQuery
      def build
        events = event_query
                   .reselect("max(#{Lookout.event.table_name}.time) - min(#{Lookout.event.table_name}.time) as duration, #{Lookout.event.table_name}.visit_id")
                   .group("#{Lookout.event.table_name}.visit_id")

        # PostgreSQL has duration type, SQLite stores as numeric seconds
        duration_cast = Lookout::DatabaseAdapter.postgresql? ? "duration::duration" : "duration"
        
        ::Ahoy::Visit
          .select("#{duration_cast} as duration, started_at")
          .from(events, :views_per_visit_table)
          .joins("inner join #{Lookout.visit.table_name} on #{Lookout.visit.table_name}.id = views_per_visit_table.visit_id")
      end
    end
  end
end
