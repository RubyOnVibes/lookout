require 'rails_helper'

RSpec.describe Lookout::FiltersConfiguration, type: :model do
  describe ".load_default" do
    it "returns FiltersConfiguration with default filters" do
      config = described_class.load_default
      expect(config).to be_a(Lookout::FiltersConfiguration)
    end

    it "registers Page filters" do
      config = described_class.load_default
      page_filters = config["Page"]
      expect(page_filters).to be_a(Lookout::FilterConfiguration::FilterCollection)
    end

    it "registers Geography filters" do
      config = described_class.load_default
      geo_filters = config["Geography"]
      expect(geo_filters).to be_a(Lookout::FilterConfiguration::FilterCollection)
    end

    it "registers all standard filter groups" do
      config = described_class.load_default
      groups = []
      config.each { |k,v| groups << k }
      expect(groups).to include("Page", "Geography", "Source", "Screen size", "Operating System", "UTM Tags")
    end
  end

  describe "#register" do
    let(:config) { described_class.new }
    
    it "registers a filter group" do
      config.register("Test Group") do
        filter column: :test_col, label: "Test", url: :test_path
      end
      
      expect(config["Test Group"]).to be_a(Lookout::FilterConfiguration::FilterCollection)
    end
  end

  describe "#each" do
    let(:config) { described_class.load_default }
    
    it "iterates over filter groups" do
      expect(config).to respond_to(:each)
      count = 0
      config.each { |name, filters| count += 1 }
      expect(count).to be > 0
    end
  end

  describe "#[]" do
    let(:config) { described_class.load_default }
    
    it "retrieves filter group by name" do
      page_filters = config["Page"]
      expect(page_filters).to be_a(Lookout::FilterConfiguration::FilterCollection)
    end
  end

  describe "#delete" do
    let(:config) { described_class.load_default }
    
    it "removes a filter group" do
      config.delete("Page")
      expect(config["Page"]).to be_nil
    end
  end

  describe "#reset" do
    let(:config) { described_class.load_default }
    
    it "clears all filters" do
      config.reset
      expect(config.instance_variable_get(:@registry)).to eq({})
    end
  end
end

