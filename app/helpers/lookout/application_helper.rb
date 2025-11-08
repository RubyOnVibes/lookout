module Lookout
  module ApplicationHelper
    include Pagy::Frontend

    def current_property_filter
      return nil unless params[:q]

      prop = params[:q].to_unsafe_h.detect { |key, _| key.starts_with?("properties.") }
      if prop
        key = prop[0].dup
        Ransack::Predicate.detect_and_strip_from_string!(key)
        { key: key, value: prop[1] }

      else
        nil
      end
    end

    def stats_container(value, url, label, formatter, selected = false)
      if value.is_a?(Lookout::ComparableQuery::Comparison)
        ::Lookout::Stats::ComparableContainerComponent.new(url, label, value, formatter, selected, compare_mode?)
      else
        ::Lookout::Stats::ContainerComponent.new(url, label, value, formatter, selected)
      end
    end

    def number_to_duration(duration)
      if duration
        minutes = duration.in_minutes.to_i
        seconds = (duration.in_seconds.to_i % 60)
        "#{minutes}m #{seconds}s"
      else
        "0m 0s"
      end
    end

    def number_to_percentage(number, options = {})
      precision = options.fetch(:precision, 2)
      "#{number.round(precision)}%"
    end

    def lookout_importmap_tags(entry_point = "application", shim: true)
      # Prefer modern helper if available (importmap-rails >= 1.1)
      if respond_to?(:javascript_importmap_tags)
        return safe_join [
          javascript_importmap_tags,
          javascript_import_module_tag(entry_point)
        ], "\n"
      end

      # Legacy helpers (importmap-rails 1.0 style) - guard per method
      parts = []
      if shim && respond_to?(:javascript_importmap_shim_tag)
        parts << javascript_importmap_shim_tag
      end
      if shim && respond_to?(:javascript_importmap_shim_nonce_configuration_tag)
        parts << javascript_importmap_shim_nonce_configuration_tag
      end
      parts << javascript_import_module_tag(entry_point)
      if respond_to?(:javascript_importmap_module_preload_tags)
        parts << javascript_importmap_module_preload_tags(Lookout.importmap)
      end
      if respond_to?(:javascript_inline_importmap_tag)
        parts << javascript_inline_importmap_tag(Lookout.importmap.to_json(resolver: self))
      end

      safe_join parts.compact, "\n"
    end

    def search_params
      request.query_parameters
    end

    # gets put into the form as a hidden field
    #
    def non_filter_ransack_params
      other_params = {}
      map = [
        :start_date,
        :end_date,
        :period,
        :interval,
        :comparison,
      ]

      # properties stuff falls into current_property_filter
      ransack = [:goal]

      map.each do |key|
        if params[key]
          other_params[key] = params[key]
        end
      end

      ransack.each do |key|
        Ransack.predicates.keys.each do |predicate|
          if value = params.dig(:q, "#{key}_#{predicate}")
            other_params["q[#{key}_#{predicate}]"] = value
          end
        end
      end

      other_params
    end

    def render_pagination
      if @pagination
        pagy_nav(@pagination).html_safe
      else
        ""
      end
    end
  end
end
