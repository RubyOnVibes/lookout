module Lookout
  module Ahoy
    module VisitMethods
      extend ActiveSupport::Concern

      included do
        ransacker :ref_domain do
          expr = Lookout::DatabaseAdapter.domain_from("#{self.table_name}.referring_domain")
          Arel.sql("(#{expr})")
        end
      end

      class_methods do
        def ransackable_attributes(auth = nil)
          columns_hash.keys + ["ref_domain"]
        end

        def ransackable_associations(auth = nil)
          super + ["events"]
        end
      end
    end
  end
end
