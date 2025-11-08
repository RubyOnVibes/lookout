# frozen_string_literal: true

class Lookout::Filter::TagComponent < ViewComponent::Base
  def initialize(tag_item:)
    @tag_item = tag_item
  end

  private 
  attr_reader :tag_item

  def modal
    tag_item.modal
  end
end
