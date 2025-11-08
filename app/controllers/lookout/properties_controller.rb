module Lookout
  class PropertiesController < ApplicationController
    before_action do
      @options = extract_property_keys.map { |key| [Base64.urlsafe_encode64(key), key]}.to_h
    end

    def index
      # Auto-select 'url' property if it exists, otherwise first property
      if @options.any?
        # Prefer 'url' property
        url_key = @options.find { |key, value| value == 'url' }&.first
        default_key = url_key || @options.keys.first
        
        redirect_to property_path(id: default_key, **request.query_parameters), status: :see_other
      end
    end

    def show
      value = Base64.urlsafe_decode64(params[:id])
      json_extract = Lookout::DatabaseAdapter.json_extract_text("properties", value)
      coalesce_expr = "COALESCE(#{json_extract}, '(none)')"

      # Handle percentage calculation differently for SQLite vs PostgreSQL
      percentage_calc = if Lookout::DatabaseAdapter.postgresql?
        "(COUNT(DISTINCT visit_id)/COUNT(*)::numeric) * 100"
      else
        "(CAST(COUNT(DISTINCT visit_id) AS REAL) / COUNT(*)) * 100"
      end

      @properties = event_query
        .select(
          "#{coalesce_expr} AS label",
          "COUNT(*) AS events_count",
          "COUNT(DISTINCT visit_id) AS unique_visitors_count",
          "#{percentage_calc} as percentage"
        )
        .group(coalesce_expr)
        .order(Arel.sql "COUNT(*) desc")
    end

    private

    helper_method :has_property?
    def has_property?(value)
      searching_properties[value]
    end

    helper_method :selected_property?
    def selected_property?(value)
      encoded = Base64.urlsafe_encode64(value, padding: false)
      encoded == params[:id]
    end

    def searching_properties
      JSON.parse(params.dig("q", "properties_json_cont") || '{}')
    end

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
