# frozen_string_literal: true

class Lookout::Filter::ModalComponent < ViewComponent::Base
  renders_one :modal_display

  def initialize(title: nil, id:)
    @title = title
    @id = id
  end

  private
  attr_reader :title, :id
end
