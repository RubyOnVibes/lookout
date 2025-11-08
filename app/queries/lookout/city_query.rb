module Lookout
  class CityQuery < ApplicationQuery
    def build
      # Use database-agnostic concat
      concat_expr = Lookout::DatabaseAdapter.concat('city', 'region', 'country')
      
      visit_query
        .select("city, country, count(#{concat_expr}) as count, sum(count(#{concat_expr})) over() as total_count")
        .where.not(city: nil)
        .group("city, region, country")
        .order(Arel.sql "count(#{concat_expr}) desc")
    end
  end
end
