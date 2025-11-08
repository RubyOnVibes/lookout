require 'rails_helper'

RSpec.describe Lookout::Funnel, type: :model do
  let(:funnel) { described_class.new }

  describe "#initialize" do
    it "initializes with nil id and label" do
      expect(funnel.id).to be_nil
      expect(funnel.instance_variable_get(:@label)).to be_nil
    end

    it "initializes empty goals array" do
      expect(funnel.goals).to eq([])
    end
  end

  describe "#goal" do
    it "adds a goal to the funnel" do
      goal = double("Goal")
      allow(Lookout.config).to receive_message_chain(:goals, :[]).with(:signup).and_return(goal)
      
      funnel.goal(:signup)
      expect(funnel.goals).to include(goal)
    end
  end

  describe "#label" do
    it "sets the label" do
      funnel.label("Test Funnel")
      expect(funnel.instance_variable_get(:@label)).to eq("Test Funnel")
    end
  end

  describe "#title" do
    it "returns the label" do
      funnel.label("My Funnel")
      expect(funnel.title).to eq("My Funnel")
    end
  end
end

RSpec.describe Lookout::FunnelCollection, type: :model do
  let(:collection) { described_class.new }

  describe "#initialize" do
    it "starts with empty hash" do
      expect(collection.instance_variable_get(:@funnels)).to eq({})
    end
  end

  describe "#register" do
    it "adds a funnel" do
      funnel = Lookout::Funnel.new
      funnel.id = :conversion
      collection.register(funnel)
      
      expect(collection[:conversion]).to eq(funnel)
    end
  end

  describe "#[]" do
    it "retrieves funnel by symbol" do
      funnel = Lookout::Funnel.new
      funnel.id = :conversion
      collection.register(funnel)
      
      expect(collection[:conversion]).to eq(funnel)
    end
  end

  describe "#each" do
    it "is enumerable" do
      expect(collection).to respond_to(:each)
      expect(collection).to be_a(Enumerable)
    end

    it "iterates over funnels" do
      funnel1 = Lookout::Funnel.new.tap { |f| f.id = :f1 }
      funnel2 = Lookout::Funnel.new.tap { |f| f.id = :f2 }
      collection.register(funnel1)
      collection.register(funnel2)
      
      funnels = []
      collection.each { |k, v| funnels << v }
      expect(funnels).to include(funnel1, funnel2)
    end
  end
end

