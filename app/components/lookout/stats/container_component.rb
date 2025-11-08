module Lookout
  module Stats
    class ContainerComponent < ViewComponent::Base
      def initialize(url, label, value, formatter, selected = false)
        @url = url
        @label = label
        @value = value
        @formatter = formatter
        @selected = selected
      end

      def formatted(value)
        public_send(@formatter, value)
      end


      def number_to_duration(duration)
        if duration && duration > 0
          minutes = (duration / 60).to_i
          seconds = (duration % 60).to_i
          "#{minutes}m #{seconds}s"
        else
          "0m 0s"
        end
      end
    end
  end
end
