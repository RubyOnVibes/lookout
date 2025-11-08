module Lookout
  class RealtimesController < ApplicationController
    def show
      @total = event_query.where("#{Lookout.event.table_name}.time > ?", 1.minute.ago).distinct(:visit_id).count(:visit_id)
    end
  end
end
