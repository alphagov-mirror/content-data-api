class Dimensions::Month < ApplicationRecord
  self.primary_key = :id

  validates :year, presence: true, numericality: { only_integer: true }
  validates :quarter, presence: true, numericality: { only_integer: true }, inclusion: { in: (1..4) }
  validates :month_number, presence: true, numericality: { only_integer: true }, inclusion: { in: (1..12) }
  validates :month_name, presence: true, inclusion: { in: ::Date::MONTHNAMES }
  validates :month_name_abbreviated, presence: true, inclusion: { in: ::Date::ABBR_MONTHNAMES }

  def self.current
    for_date(Time.zone.today)
  end

  def self.create_with(date)
    month_dimension = build(date)
    month_dimension.save!
    month_dimension
  end

  def self.for_date(date)
    find_by(id: format_id(date)) || create_with(date)
  end

  def self.build(date)
    new(
      id: format_id(date),
      month_number: date.month,
      month_name: date.strftime('%B'),
      month_name_abbreviated: date.strftime('%b'),
      year: date.year,
      quarter: ((date.month - 1) / 3) + 1,
    )
  end

  def self.format_id(date)
    format('%04d-%02d', date.year, date.month)
  end
end
