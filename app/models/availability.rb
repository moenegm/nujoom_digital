class Availability < ApplicationRecord
  belongs_to :provider

  validates :day_of_week, inclusion: { in: 0..6 }
  validates :start_time, :end_time, presence: true
end
