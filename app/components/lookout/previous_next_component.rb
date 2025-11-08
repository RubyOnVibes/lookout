module Lookout
  class PreviousNextComponent < ViewComponent::Base
    def initialize(range)
      @range = range
    end

    def render?
      false
    end
  end
end
