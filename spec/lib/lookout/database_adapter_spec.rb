require "rails_helper"

RSpec.describe Lookout::DatabaseAdapter, type: :model do
  before do
    described_class.reset!
  end

  describe ".build_url_column" do
    it "generates PG SQL with CONCAT and ->>" do
      allow(described_class).to receive(:postgresql?).and_return(true)
      allow(described_class).to receive(:sqlite?).and_return(false)

      sql = described_class.build_url_column("ahoy_events")
      expect(sql).to include("CONCAT(")
      expect(sql).to include("ahoy_events.properties->>'controller'")
      expect(sql).to include("ahoy_events.properties->>'action'")
    end

    it "generates SQLite SQL with || and JSON_EXTRACT" do
      allow(described_class).to receive(:postgresql?).and_return(false)
      allow(described_class).to receive(:sqlite?).and_return(true)

      sql = described_class.build_url_column("ahoy_events")
      expect(sql).to include("|| '#'")
      expect(sql).to include("JSON_EXTRACT(ahoy_events.properties, '$.controller')")
      expect(sql).to include("JSON_EXTRACT(ahoy_events.properties, '$.action')")
    end
  end

  describe ".json_key_exists" do
    it "generates PG JSONB_EXISTS" do
      allow(described_class).to receive(:postgresql?).and_return(true)
      allow(described_class).to receive(:sqlite?).and_return(false)

      sql = described_class.json_key_exists("ahoy_events.properties", "controller")
      expect(sql).to eq("JSONB_EXISTS(ahoy_events.properties, 'controller')")
    end

    it "generates SQLite JSON_TYPE IS NOT NULL" do
      allow(described_class).to receive(:postgresql?).and_return(false)
      allow(described_class).to receive(:sqlite?).and_return(true)

      sql = described_class.json_key_exists("ahoy_events.properties", "controller")
      expect(sql).to eq("JSON_TYPE(ahoy_events.properties, '$.controller') IS NOT NULL")
    end
  end

  describe ".percentage_calculation" do
    it "uses numeric cast for PG" do
      allow(described_class).to receive(:postgresql?).and_return(true)
      allow(described_class).to receive(:sqlite?).and_return(false)

      sql = described_class.percentage_calculation("COUNT(DISTINCT visit_id)", "COUNT(*)")
      expect(sql).to eq("(COUNT(DISTINCT visit_id)/COUNT(*)::numeric) * 100")
    end

    it "uses REAL cast for SQLite" do
      allow(described_class).to receive(:postgresql?).and_return(false)
      allow(described_class).to receive(:sqlite?).and_return(true)

      sql = described_class.percentage_calculation("COUNT(DISTINCT visit_id)", "COUNT(*)")
      expect(sql).to eq("(CAST(COUNT(DISTINCT visit_id) AS REAL) / COUNT(*)) * 100")
    end
  end
end
