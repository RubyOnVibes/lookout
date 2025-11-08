module Lookout
  module Filters
    class GoalsController < BaseController
      def index
        render json: Lookout.configuration.goals.map { |goal| { text: goal.title, value: goal.id } }
      end
    end
  end
end
