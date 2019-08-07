class UpdateAggregationsSearchLastThirtyDaysToVersion7 < ActiveRecord::Migration[5.2]
  def change
    update_view :aggregations_search_last_thirty_days,
                version: 7,
                revert_to_version: 6,
                materialized: true
  end
end
