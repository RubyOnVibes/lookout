module Lookout
  module Filters
    class BaseController < ApplicationController
      private

      def serialize(value)
        { text: (value.presence || Lookout.none.text), value: (value.presence || Lookout.none.value) }
      end

      def visit_query
        VisitQuery.call(params)
      end
    end
  end
end
