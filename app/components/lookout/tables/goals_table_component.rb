module Lookout
  module Tables
    class GoalsTableComponent < DynamicTable
      register fixed_height: false do
        progress_bar value: :cr, max: 100, title: "Name" do |row|
          search_params = view_context.search_params
          query = search_params.dup.merge(q: { goal_in: row.goal_id}).to_query
          url = Lookout::Engine.app.url_helpers.root_path + "?#{query}"
          link_to row.item.name, url, target: :_top
        end
        number :unique_visits, title: "Uniq"
        number :total_events, title: "All"
        percent :cr, title: "CR"
      end
    end
  end
end
