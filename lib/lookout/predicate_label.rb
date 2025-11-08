module Lookout
  class PredicateLabel
    def self.[](value)
      Lookout.config.predicate_labels[value.to_sym] || value.to_s.titleize
    end
  end
end
