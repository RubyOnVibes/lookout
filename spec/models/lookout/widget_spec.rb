require 'rails_helper'

RSpec.describe Lookout::Widget, type: :model do
  describe ".disabled?" do
    context "when widget is in disabled list" do
      before do
        allow(Lookout.config).to receive(:disabled_widgets).and_return(['test_widget'])
      end

      it "returns true" do
        expect(Lookout::Widget.disabled?('test_widget')).to be true
      end
    end

    context "when widget is not disabled" do
      before do
        allow(Lookout.config).to receive(:disabled_widgets).and_return([])
      end

      it "returns false" do
        expect(Lookout::Widget.disabled?('enabled_widget')).to be false
      end
    end

    context "with multiple widget names" do
      before do
        allow(Lookout.config).to receive(:disabled_widgets).and_return(['parent.child'])
      end

      it "joins names with dot" do
        expect(Lookout::Widget.disabled?('parent', 'child')).to be true
      end
    end
  end

  describe "::WidgetDisabled" do
    it "is a StandardError" do
      expect(Lookout::Widget::WidgetDisabled.new("test")).to be_a(StandardError)
    end

    it "stores frame attribute" do
      error = Lookout::Widget::WidgetDisabled.new("test message", "test_frame")
      expect(error.frame).to eq("test_frame")
    end
  end
end
