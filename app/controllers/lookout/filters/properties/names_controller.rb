module Lookout
  module Filters
    module Properties
      class NamesController < BaseController
        def index
          keys = extract_property_keys
          render json: keys.map { |key| serialize(key) }
        end

        private

        def extract_property_keys
          if Lookout::DatabaseAdapter.postgresql?
            ::Ahoy::Event
              .select("jsonb_object_keys(properties) as keys")
              .distinct
              .pluck("jsonb_object_keys(properties)")
          else
            # SQLite: use json_each to extract keys
            ::Ahoy::Event
              .from("#{::Ahoy::Event.table_name}, json_each(#{::Ahoy::Event.table_name}.properties)")
              .select("DISTINCT json_each.key as keys")
              .pluck("json_each.key")
          end
        end
      end
    end
  end
end
