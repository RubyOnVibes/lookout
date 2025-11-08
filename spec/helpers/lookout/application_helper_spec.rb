require 'rails_helper'

RSpec.describe Lookout::ApplicationHelper, type: :helper do
  describe "#number_to_duration" do
    it "formats duration with minutes and seconds" do
      duration = 245.seconds
      expect(helper.number_to_duration(duration)).to eq("4m 5s")
    end

    it "handles zero seconds" do
      duration = 60.seconds
      expect(helper.number_to_duration(duration)).to eq("1m 0s")
    end

    it "handles nil duration" do
      expect(helper.number_to_duration(nil)).to eq("0m 0s")
    end

    it "handles long durations" do
      duration = 3665.seconds # 1 hour 1 minute 5 seconds
      expect(helper.number_to_duration(duration)).to eq("61m 5s")
    end
  end

  describe "#number_to_percentage" do
    it "rounds to 2 decimals by default" do
      expect(helper.number_to_percentage(10.8145)).to eq("10.81%")
    end

    it "respects custom precision" do
      expect(helper.number_to_percentage(10.8145, precision: 1)).to eq("10.8%")
      expect(helper.number_to_percentage(10.8145, precision: 3)).to eq("10.815%")
    end

    it "handles whole numbers" do
      expect(helper.number_to_percentage(50.0)).to eq("50.0%")
    end

    it "handles zero" do
      expect(helper.number_to_percentage(0.0)).to eq("0.0%")
    end
  end

  describe "#current_property_filter" do
    it "returns nil when no q params" do
      allow(helper).to receive(:params).and_return({})
      expect(helper.current_property_filter).to be_nil
    end

    it "extracts property filter from params" do
      params = { q: { "properties.user_id_eq" => "123" } }
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(params))
      
      result = helper.current_property_filter
      expect(result).to be_a(Hash)
      expect(result[:key]).to eq("properties.user_id")
      expect(result[:value]).to eq("123")
    end

    it "strips ransack predicates from key" do
      params = { q: { "properties.email_cont" => "test" } }
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(params))
      
      result = helper.current_property_filter
      expect(result[:key]).to eq("properties.email")
    end

    it "returns nil when no properties filters" do
      params = { q: { "goal_eq" => "signup" } }
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(params))
      
      expect(helper.current_property_filter).to be_nil
    end
  end

  describe "#stats_container" do
    let(:url) { "/stats/test" }
    let(:label) { "Test Stat" }
    let(:formatter) { :number }

    xit "returns ComparableContainerComponent for comparison value" do
      # Skip for now - complex mocking
      # TODO: Test with actual Comparison object
    end

    it "returns ContainerComponent for simple value" do
      value = 100
      
      result = helper.stats_container(value, url, label, formatter)
      expect(result).to be_a(Lookout::Stats::ContainerComponent)
    end
  end

  describe "#lookout_importmap_tags" do
    it "generates importmap tags" do
      allow(helper).to receive(:respond_to?).and_call_original
      allow(helper).to receive(:respond_to?).with(:javascript_importmap_tags).and_return(false)
      allow(helper).to receive(:respond_to?).with(:javascript_import_module_tag).and_return(true)
      allow(helper).to receive(:javascript_import_module_tag).with(any_args).and_return("<script>")
      
      result = helper.lookout_importmap_tags
      expect(result).to be_a(String)
    end
  end

  describe "#search_params" do
    it "returns request query parameters" do
      params = { period: "7d", start_date: "2025-01-01" }
      allow(helper).to receive_message_chain(:request, :query_parameters).and_return(params)
      
      expect(helper.search_params).to eq(params)
    end
  end

  describe "#non_filter_ransack_params" do
    it "extracts non-filter params" do
      params = ActionController::Parameters.new({
        period: "7d",
        start_date: "2025-01-01",
        q: { goal_eq: "signup" }
      })
      allow(helper).to receive(:params).and_return(params)
      
      result = helper.non_filter_ransack_params
      expect(result[:period]).to eq("7d")
      expect(result[:start_date]).to eq("2025-01-01")
      expect(result["q[goal_eq]"]).to eq("signup")
    end

    it "handles missing params gracefully" do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new({}))
      
      result = helper.non_filter_ransack_params
      expect(result).to be_a(Hash)
      expect(result).to be_empty
    end
  end

  describe "#render_pagination" do
    it "renders pagy nav when pagination exists" do
      pagination = double("Pagy")
      helper.instance_variable_set(:@pagination, pagination)
      allow(helper).to receive(:pagy_nav).with(pagination).and_return("<nav>test</nav>")
      
      expect(helper.render_pagination).to eq("<nav>test</nav>")
    end

    it "returns empty string when no pagination" do
      helper.instance_variable_set(:@pagination, nil)
      
      expect(helper.render_pagination).to eq("")
    end
  end
end
