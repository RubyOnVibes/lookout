# frozen_string_literal: true

class Lookout::StickyNavComponent < ViewComponent::Base
  renders_one :realtime_update
  include ::Lookout::CompareMode
  include ::Lookout::RangeOptions
  include ::Lookout::Rangeable

  def filters
    @filters ||= ::Lookout::FilterParser.parse(request)
  end

  def custom_range_label
    if range.custom?
      [range.starts_at, range.ends_at].map { |date| date.strftime('%b %d, %Y') }.join("-")
    else
      "Custom Range"
    end
  end

  def tag_list_hidden?
    filters.values.map(&:values).flatten.size < ::Lookout::FilterParser::FILTER_MENU_MAX_SIZE
  end
end
