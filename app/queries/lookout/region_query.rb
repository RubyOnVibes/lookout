module Lookout
  class RegionQuery < ApplicationQuery
    def build
      # Use database-agnostic concat
      concat_expr = Lookout::DatabaseAdapter.concat('region', 'country')
      
      visit_query
        .reselect("region, country, count(#{concat_expr}) as count, sum(count(region)) over() as total_count")
        .where.not(region: nil)
        .group("region, country")
        .order(Arel.sql "count(#{concat_expr}) desc")
    end
  end
end
