class Availability < ApplicationRecord
  belongs_to :provider

  DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]

  validates :day_of_week, inclusion: { in: 0..6 }
  validates :start_time, :end_time, presence: true

  def day_name
    DAY_NAMES[day_of_week]
  end
end
