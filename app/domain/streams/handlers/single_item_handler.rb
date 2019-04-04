class Streams::Handlers::SingleItemHandler < Streams::Handlers::BaseHandler
  class MissingLocaleError < StandardError
  end

  def self.process(*args)
    new(*args).process
  end

  def initialize(attrs, payload, routing_key)
    @attrs = attrs
    @payload = payload
    @routing_key = routing_key
  end

  attr_reader :attrs, :old_edition

  def process
    update_editions [attrs: attrs, old_edition: find_old_edition(attrs[:warehouse_item_id], attrs[:locale])]
  end

private

  def find_old_edition(warehouse_item_id, locale)
    raise MissingLocaleError unless locale

    Dimensions::Edition.find_latest(warehouse_item_id)
  end
end
