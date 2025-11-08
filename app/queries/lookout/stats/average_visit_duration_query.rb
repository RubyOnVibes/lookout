module Lookout
  module Stats
    class AverageVisitDurationQuery < BaseQuery
      def build
        max_events = event_query.select("#{Lookout.event.table_name}.visit_id, max(#{Lookout.event.table_name}.time) as created_at").group("visit_id")
        
        # PostgreSQL has interval type, SQLite stores timestamp diff as numeric (seconds)
        duration_cast = Lookout::DatabaseAdapter.postgresql? ? 
          "avg((max_events.created_at - #{Lookout.visit.table_name}.started_at))::interval" :
          "avg(julianday(max_events.created_at) - julianday(#{Lookout.visit.table_name}.started_at)) * 86400"
        
        visit_query.select("#{duration_cast} as average_visit_duration")
                   .joins("LEFT JOIN (#{max_events.to_sql}) as max_events ON #{Lookout.visit.table_name}.id = max_events.visit_id")
      end

      def self.cast_type(value)
        ActiveRecord::Type.lookup(:string)
      end

      def self.cast_value(_type, value)
        if value.present?
          # SQLite returns numeric seconds, PostgreSQL returns interval string
          if value.is_a?(Numeric) || value.to_s.match?(/^\d+(\.\d+)?$/)
            value.to_f.seconds
          else
            ActiveSupport::Duration.parse(value)
          end
        else
          0.seconds
        end
      end
    end
  end
end
