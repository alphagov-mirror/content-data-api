class Etl::Aggregations::Search
  include Concerns::Traceable

  def self.process(*args)
    new(*args).process
  end

  def process
    do_process(::Aggregations::SearchLastThirtyDays)
    do_process(::Aggregations::SearchLastMonth)
    do_process(::Aggregations::SearchLastThreeMonths)
    do_process(::Aggregations::SearchLastSixMonths)
    do_process(::Aggregations::SearchLastTwelveMonths)
  end

private

  def do_process(klass)
    name = klass.name.demodulize.underscore
    time(process: name) { klass.refresh }
  end
end
