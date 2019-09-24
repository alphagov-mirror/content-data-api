class AddIndexesViewAggregationsSearchLastThirtyDays < ActiveRecord::Migration[5.2]
  def up
    execute "create index aggregations_search_last_thirty_days_gin_base_path on aggregations_search_last_thirty_days using gin(to_tsvector('english'::regconfig, replace((base_path)::text, '/'::text, ' '::text)))"
    execute "create index aggregations_search_last_thirty_days_gin_title on aggregations_search_last_thirty_days  using gin(to_tsvector('english', title ))"

    add_index :aggregations_search_last_thirty_days, :upviews, name: :search_last_thirty_days_gin_base_path_upviews
    add_index :aggregations_search_last_thirty_days, %i[organisation_id upviews], name: :search_last_thirty_days_gin_base_path_organisation_id
    add_index :aggregations_search_last_thirty_days, %i[document_type upviews], name: :search_last_thirty_days_gin_base_path_document_type
  end

  def down
    execute "drop index aggregations_search_last_thirty_days_gin_base_path"
    execute "drop index aggregations_search_last_thirty_days_gin_title"

    remove_index :aggregations_search_last_thirty_days, name: :search_last_thirty_days_gin_base_path_upviews
    remove_index :aggregations_search_last_thirty_days, name: :search_last_thirty_days_gin_base_path_organisation_id
    remove_index :aggregations_search_last_thirty_days, name: :search_last_thirty_days_gin_base_path_document_type
  end
end
