module Lookout
  class VisitQuery < ApplicationQuery

    def build
      shared_context = Ransack::Context.for(Lookout.visit)

      visit_params = ransack_params_for(:visit).reject { |k,v| k.start_with?("events_") }
      event_params = ransack_params_for(:event).reject { |k,v| k.start_with?("visit_") }

      # Detect if event_params contain only time constraints (and related visit time injects)
      time_keys = %w[time_gt time_lt time_gteq time_lteq visit_started_at_gt visit_started_at_lt]
      event_params_without_time = event_params.reject { |k,_| time_keys.include?(k.to_s) || k.to_s.start_with?("c[") }
      # Keep composite conditions under :c if present (properties), so detect them as filters
      has_event_filters = event_params_without_time.any? || event_params.key?(:c)

      if has_event_filters
        search_parents = Lookout.visit.ransack(visit_params, context: shared_context)
        search_children = Lookout.event.ransack(event_params.transform_keys { |key| "events_#{key}" }, context: shared_context)

        shared_conditions = [search_parents, search_children].map { |search|
          Ransack::Visitor.new.accept(search.base)
        }

        Lookout.visit.joins(shared_context.join_sources)
              .where(shared_conditions.reduce(&:and))
      else
        # No event filters: do not join events; rely on visit constraints only
        search_parents = Lookout.visit.ransack(visit_params, context: shared_context)
        Lookout.visit.where(Ransack::Visitor.new.accept(search_parents.base))
      end

    end

    def is_a?(other)
      if other == ActiveRecord::Relation
        return true
      end

      super(other)
    end
  end
end
