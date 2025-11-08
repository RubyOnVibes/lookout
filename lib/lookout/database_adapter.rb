module Lookout
  module DatabaseAdapter
    class << self
      # Detect the database adapter being used
      def adapter_name
        @adapter_name ||= detect_adapter
      end

      # Reset cached adapter name (useful for testing)
      def reset!
        @adapter_name = nil
      end

      def postgresql?
        adapter_name == :postgresql
      end

      def sqlite?
        adapter_name == :sqlite
      end

      # Generate SQL for concatenating strings
      def concat(*args)
        if postgresql?
          "CONCAT(#{args.join(', ')})"
        else # sqlite
          args.join(' || ')
        end
      end

      # Generate SQL for extracting JSON text value
      # Usage: json_extract_text('properties', 'controller')
      def json_extract_text(column, key)
        if postgresql?
          "#{column}->>'#{key}'"
        else # sqlite
          "JSON_EXTRACT(#{column}, '$.#{key}')"
        end
      end

      # Generate SQL for checking if JSON key exists
      def json_key_exists(column, key)
        if postgresql?
          "JSONB_EXISTS(#{column}, '#{key}')"
        else # sqlite
          "JSON_TYPE(#{column}, '$.#{key}') IS NOT NULL"
        end
      end

      # Generate SQL for getting all JSON object keys
      # Returns a query that produces rows with a 'keys' column
      def json_object_keys(column)
        if postgresql?
          "jsonb_object_keys(#{column})"
        else # sqlite
          # SQLite doesn't have a built-in function for this
          # We'll need to use json_each which returns key/value pairs
          # This will be used in a subquery context
          "json_each.key"
        end
      end

      # Generate the FROM clause for getting JSON keys
      # For SQLite, we need to use json_each()
      def json_keys_from_clause(table_name, column)
        if postgresql?
          table_name
        else # sqlite
          "#{table_name}, json_each(#{table_name}.#{column})"
        end
      end

      # Generate SQL for JSON contains check (for ransacker)
      def json_infix_operator
        if postgresql?
          '->>'
        else # sqlite
          # We'll handle this differently in SQLite
          # Return a marker that we can detect and handle specially
          'JSON_EXTRACT'
        end
      end

      # Generate SQL for building URL from controller/action in properties
      # table_name: the table name (e.g., 'ahoy_events')
      def build_url_column(table_name)
        controller = json_extract_text("#{table_name}.properties", 'controller')
        action = json_extract_text("#{table_name}.properties", 'action')
        
        if postgresql?
          "CONCAT(#{controller}, '#', #{action})"
        else # sqlite
          "#{controller} || '#' || #{action}"
        end
      end

      # Generate SQL for checking if URL properties exist
      def build_url_exists(table_name)
        controller_exists = json_key_exists("#{table_name}.properties", 'controller')
        action_exists = json_key_exists("#{table_name}.properties", 'action')
        
        "#{controller_exists} AND #{action_exists}"
      end

      # For SQLite JSON_EXTRACT in ransacker, we need special handling
      def ransacker_json_extract(parent, key)
        if postgresql?
          Arel::Nodes::InfixOperation.new('->>', parent.table[:properties], Arel::Nodes.build_quoted(key))
        else # sqlite
          Arel::Nodes::NamedFunction.new(
            'JSON_EXTRACT',
            [parent.table[:properties], Arel::Nodes.build_quoted("$.#{key}")]
          )
        end
      end

      # Extract domain from a referrer/URL column
      # column can be a bare column (referring_domain) or qualified (table.referring_domain)
      def domain_from(column)
        if postgresql?
          # Use regex form supported by Postgres
          "substring(#{column} from '(?:.*://)?(?:www\\.)?([^/?]*)')"
        else
          # SQLite: derive domain using instr/substr
          # Step 1: strip scheme
          base = "CASE WHEN instr(#{column}, '://') > 0 THEN substr(#{column}, instr(#{column}, '://') + 3) ELSE #{column} END"
          # Step 2: strip leading www.
          no_www = "CASE WHEN substr(#{base}, 1, 4) = 'www.' THEN substr(#{base}, 5) ELSE #{base} END"
          # Step 3: take up to first '/'
          "CASE WHEN instr(#{no_www}, '/') > 0 THEN substr(#{no_www}, 1, instr(#{no_www}, '/') - 1) ELSE #{no_www} END"
        end
      end

      # Cast a number to decimal/real for percentage calculations
      def numeric_cast(expression)
        if postgresql?
          "#{expression}::numeric"
        else # sqlite
          "CAST(#{expression} AS REAL)"
        end
      end

      # Calculate percentage: (numerator / denominator) * 100
      def percentage_calculation(numerator, denominator)
        if postgresql?
          "(#{numerator}/#{denominator}::numeric) * 100"
        else # sqlite
          "(CAST(#{numerator} AS REAL) / #{denominator}) * 100"
        end
      end

      private

      def detect_adapter
        name = ActiveRecord::Base.connection_db_config.adapter.to_s
        case name
        when /postg/i
          :postgresql
        when /sqlite/i
          :sqlite
        else
          raise "Unsupported database adapter: #{name}. Lookout supports PostgreSQL and SQLite only."
        end
      end
    end
  end
end

