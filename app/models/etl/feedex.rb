class ETL::Feedex
  def self.process(*args)
    new(*args).process
  end

  def initialize(date:)
    @date = date
  end

  def process
    extract_events
    load_metrics
  end

private

  BATCH_SIZE = 10_000

  def extract_events
    feedex_service.find_in_batches do |events|
      Events::Feedex.import(events, batch_size: BATCH_SIZE)
    end
  end

  def load_metrics
    conn = ActiveRecord::Base.connection
    date_to_s = date.strftime("%F")

    conn.execute(load_metrics_query(date_to_s))
    conn.execute(clean_up_query)
  end

  def load_metrics_query(date_to_s)
    <<~SQL
      UPDATE facts_metrics
      SET number_of_issues = s.number_of_issues
      FROM (
        SELECT base_path,
               number_of_issues,
               dimensions_items.id
        FROM events_feedexes, dimensions_items
        WHERE page_path = base_path
          AND events_feedexes.date = '#{date_to_s}'
      ) AS s
      WHERE dimensions_item_id = s.id AND dimensions_date_id = '#{date_to_s}'
    SQL
  end

  def clean_up_query
    date_to_s = date.strftime("%F")
    <<~SQL
      DELETE FROM events_feedexes
      WHERE date = '#{date_to_s}' AND
        page_path in (
           SELECT base_path
           FROM dimensions_items, facts_metrics
           WHERE dimensions_items.id = facts_metrics.dimensions_item_id
           AND facts_metrics.dimensions_date_id = '#{date_to_s}'
        )
    SQL
  end

  attr_reader :date

  def feedex_service
    @feedex_service ||= FeedexService.new(date, BATCH_SIZE)
  end
end