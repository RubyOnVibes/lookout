require "rails_helper"

RSpec.describe Lookout::DatabaseAdapter, type: :model do
  before do
    described_class.reset!
  end

  describe ".concat" do
    it "generates PG CONCAT function" do
      allow(described_class).to receive(:postgresql?).and_return(true)
      allow(described_class).to receive(:sqlite?).and_return(false)

      sql = described_class.concat("'a'", "'b'", "'c'")
      expect(sql).to eq("CONCAT('a', 'b', 'c')")
    end

    it "generates SQLite || operator" do
      allow(described_class).to receive(:postgresql?).and_return(false)
      allow(described_class).to receive(:sqlite?).and_return(true)

      sql = described_class.concat("'a'", "'b'", "'c'")
      expect(sql).to eq("'a' || 'b' || 'c'")
    end
  end

  describe ".json_extract_text" do
    it "generates PG ->> operator" do
      allow(described_class).to receive(:postgresql?).and_return(true)
      allow(described_class).to receive(:sqlite?).and_return(false)

      sql = described_class.json_extract_text("properties", "url")
      expect(sql).to eq("properties->>'url'")
    end

    it "generates SQLite JSON_EXTRACT" do
      allow(described_class).to receive(:postgresql?).and_return(false)
      allow(described_class).to receive(:sqlite?).and_return(true)

      sql = described_class.json_extract_text("properties", "url")
      expect(sql).to eq("JSON_EXTRACT(properties, '$.url')")
    end
  end

  describe ".json_object_keys" do
    it "generates PG jsonb_object_keys" do
      allow(described_class).to receive(:postgresql?).and_return(true)
      allow(described_class).to receive(:sqlite?).and_return(false)

      sql = described_class.json_object_keys("properties")
      expect(sql).to eq("jsonb_object_keys(properties)")
    end

    it "generates SQLite json_each.key" do
      allow(described_class).to receive(:postgresql?).and_return(false)
      allow(described_class).to receive(:sqlite?).and_return(true)

      sql = described_class.json_object_keys("properties")
      expect(sql).to eq("json_each.key")
    end
  end

  describe ".json_keys_from_clause" do
    it "returns table name for PG" do
      allow(described_class).to receive(:postgresql?).and_return(true)
      allow(described_class).to receive(:sqlite?).and_return(false)

      clause = described_class.json_keys_from_clause("ahoy_events", "properties")
      expect(clause).to eq("ahoy_events")
    end

    it "generates json_each cross join for SQLite" do
      allow(described_class).to receive(:postgresql?).and_return(false)
      allow(described_class).to receive(:sqlite?).and_return(true)

      clause = described_class.json_keys_from_clause("ahoy_events", "properties")
      expect(clause).to eq("ahoy_events, json_each(ahoy_events.properties)")
    end
  end

  describe ".numeric_cast" do
    it "uses ::numeric for PG" do
      allow(described_class).to receive(:postgresql?).and_return(true)
      allow(described_class).to receive(:sqlite?).and_return(false)

      sql = described_class.numeric_cast("COUNT(*)")
      expect(sql).to eq("COUNT(*)::numeric")
    end

    it "uses CAST AS REAL for SQLite" do
      allow(described_class).to receive(:postgresql?).and_return(false)
      allow(described_class).to receive(:sqlite?).and_return(true)

      sql = described_class.numeric_cast("COUNT(*)")
      expect(sql).to eq("CAST(COUNT(*) AS REAL)")
    end
  end

  describe ".domain_from" do
    it "uses substring regex for PG" do
      allow(described_class).to receive(:postgresql?).and_return(true)
      allow(described_class).to receive(:sqlite?).and_return(false)

      sql = described_class.domain_from("referring_domain")
      expect(sql).to include("substring(referring_domain from")
      expect(sql).to include("(?:.*://)?(?:www\\.)?([^/?]*)")
    end

    it "uses CASE/substr/instr for SQLite" do
      allow(described_class).to receive(:postgresql?).and_return(false)
      allow(described_class).to receive(:sqlite?).and_return(true)

      sql = described_class.domain_from("referring_domain")
      expect(sql).to include("CASE WHEN")
      expect(sql).to include("instr(")
      expect(sql).to include("substr(")
    end
  end

  describe ".adapter_name" do
    it "detects current database adapter" do
      # Test against actual database (PostgreSQL in test suite)
      described_class.reset!
      
      adapter = described_class.adapter_name
      expect([:postgresql, :sqlite]).to include(adapter)
      
      # Should have one of the predicates return true
      expect(described_class.postgresql? || described_class.sqlite?).to be true
    end

    it "caches adapter detection" do
      described_class.reset!
      first_call = described_class.adapter_name
      second_call = described_class.adapter_name
      
      expect(first_call).to eq(second_call)
      expect(first_call).to be_a(Symbol)
    end

    it "reset! clears cached adapter" do
      described_class.adapter_name # Cache it
      described_class.reset!
      
      # After reset, should detect again
      expect(described_class.instance_variable_get(:@adapter_name)).to be_nil
    end
  end
end

