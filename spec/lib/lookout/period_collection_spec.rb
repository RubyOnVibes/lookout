require 'rails_helper'

RSpec.describe Lookout::PeriodCollection, type: :model do
  describe ".load_default" do
    it "returns a PeriodCollection with default periods" do
      collection = described_class.load_default
      expect(collection).to be_a(Lookout::PeriodCollection)
      count = 0
      collection.each { |k,v| count += 1 }
      expect(count).to be > 0
    end

    it "includes standard periods" do
      collection = described_class.load_default
      expect(collection.find(:realtime)).to be_a(Lookout::PeriodCollection::Period)
      expect(collection.find('7d')).to be_a(Lookout::PeriodCollection::Period)
      expect(collection.find(:mtd)).to be_a(Lookout::PeriodCollection::Period)
    end
  end

  describe "#add" do
    let(:collection) { described_class.new }
    
    it "adds a period with range proc" do
      range_proc = -> { [1.day.ago, Time.current] }
      collection.add(:custom, "Custom", range_proc)
      period = collection.find(:custom)
      
      expect(period).to be_a(Lookout::PeriodCollection::Period)
      expect(period.label).to eq("Custom")
      expect(period.param).to eq(:custom)
    end

    it "validates range is callable" do
      expect {
        collection.add(:bad, "Bad", "not a proc")
      }.to raise_error(ArgumentError, /range must be a proc/)
    end

    it "validates range returns array or range" do
      expect {
        collection.add(:bad, "Bad", -> { "string" })
      }.to raise_error(ArgumentError, /must return a range or an array/)
    end
  end

  describe "#delete" do
    let(:collection) { described_class.load_default }
    
    it "removes a period" do
      collection.delete(:realtime)
      expect(collection.find(:realtime)).to be_nil
    end
  end

  describe "#default" do
    let(:collection) { described_class.load_default }
    
    it "returns default period key" do
      expect(collection.default).to be_a(Symbol)
      expect(collection.default).to eq(:'30d')
    end
  end

  describe "#default=" do
    let(:collection) { described_class.load_default }
    
    it "sets the default period" do
      collection.default = :'7d'
      expect(collection.default).to eq(:'7d')
    end
  end

  describe "#find" do
    let(:collection) { described_class.load_default }
    
    it "finds period by symbol" do
      period = collection.find(:'7d')
      expect(period).to be_a(Lookout::PeriodCollection::Period)
      expect(period.label).to eq("7 Days")
    end

    it "finds period by string" do
      period = collection.find('7d')
      expect(period).to be_a(Lookout::PeriodCollection::Period)
    end

    it "returns nil for non-existent period" do
      expect(collection.find(:nonexistent)).to be_nil
    end
  end


  describe "#each" do
    let(:collection) { described_class.load_default }
    
    it "iterates over periods" do
      expect(collection).to respond_to(:each)
      count = 0
      collection.each { |k, v| count += 1 }
      expect(count).to be > 0
    end
  end

  describe "#count" do
    let(:collection) { described_class.load_default }
    
    it "returns number of periods" do
      periods_count = 0
      collection.each { |k,v| periods_count += 1 }
      expect(periods_count).to be > 5
    end
  end

  describe "#for" do
    let(:collection) { described_class.load_default }
    
    it "returns range for given period" do
      result = collection.for(:'7d')
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
    end

    it "returns default when value is nil" do
      result = collection.for(nil)
      expect(result).to be_an(Array)
    end

    it "returns default when period not found" do
      result = collection.for(:nonexistent)
      expect(result).to be_an(Array)
    end
  end

  describe "#reset" do
    let(:collection) { described_class.load_default }
    
    it "clears all periods" do
      collection.reset
      expect(collection.instance_variable_get(:@periods)).to eq({})
      expect(collection.default).to be_nil
    end
  end

  describe "#all" do
    let(:collection) { described_class.load_default }
    
    it "returns periods hash" do
      expect(collection.all).to be_a(Hash)
      expect(collection.all.keys).to include(:'7d', :'30d', :mtd)
    end
  end

  describe "#max" do
    let(:collection) { described_class.new }
    
    it "gets max range duration" do
      collection.max = 100.days
      expect(collection.max).to eq(100.days)
    end
  end
end

RSpec.describe Lookout::PeriodCollection::Period, type: :model do
  describe "#initialize" do
    it "sets param, label, and range" do
      range_proc = -> { [1.day.ago, Time.current] }
      period = described_class.new(param: :test, label: "Test", range: range_proc)
      
      expect(period.param).to eq(:test)
      expect(period.label).to eq("Test")
      expect(period.range).to eq(range_proc)
    end
  end
end

