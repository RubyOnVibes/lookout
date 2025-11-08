module Lookout
  module Rangeable
    def period
      params[:period] || Lookout.config.ranges.default
    end
  end
end
