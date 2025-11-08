module Lookout
  class EntryPagesQuery < ApplicationQuery

    def build
      max_id_query = event_query.with_routes.select("min(#{Lookout.event.table_name}.id) as id").group("visit_id")
      event_query.with_routes.select(
        "#{Lookout.config.event[:url_column]} as url",
        "count(#{Lookout.config.event[:url_column]}) as count",
        "sum(count(#{Lookout.config.event[:url_column]})) over() as total_count"
      )
                     .where(id: max_id_query)
                     .group(Lookout.config.event[:url_column])
                     .order(Arel.sql "count(#{Lookout.config.event[:url_column]}) desc")
    end


  end
end
