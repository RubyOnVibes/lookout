module Lookout
  class FunnelsController < ApplicationController
    def show
      funnel = Lookout.configuration.funnels[params[:id]]
      @funnel = FunnelPresenter.new(funnel, event_query).build
    end
  end
end
