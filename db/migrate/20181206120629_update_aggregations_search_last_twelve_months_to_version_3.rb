class UpdateAggregationsSearchLastTwelveMonthsToVersion3 < ActiveRecord::Migration[5.2]
  def change
    update_view :aggregations_search_last_twelve_months, version: 3, revert_to_version: 2, materialized: true
  end
end
