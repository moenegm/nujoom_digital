class Provider < ApplicationRecord
  has_many :availabilities
  has_many :bookings

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  SLOT_MINUTES = 30

  # Returns the next `count` calendar dates (starting tomorrow) that this
  # provider has at least one availability window on.
  def open_days(count: 6, start_date: Date.tomorrow)
    days = []
    date = start_date
    # Safety cap so a provider with zero availabilities can't loop forever.
    max_lookahead = start_date + 60
    while days.size < count && date <= max_lookahead
      days << date if availabilities.exists?(day_of_week: date.wday)
      date += 1
    end
    days
  end

  # Returns every bookable slot start time (as a Time, in Time.zone) for the
  # given date, based on this provider's availability windows for that
  # weekday, cut into SLOT_MINUTES chunks.
  def slots_on(date)
    availabilities.where(day_of_week: date.wday).order(:start_time).flat_map do |availability|
      slots_for_window(date, availability.start_time, availability.end_time)
    end
  end

  private

  def slots_for_window(date, start_time, end_time)
    slots = []
    current = Time.zone.local(date.year, date.month, date.day, start_time.hour, start_time.min)
    finish = Time.zone.local(date.year, date.month, date.day, end_time.hour, end_time.min)
    while current + SLOT_MINUTES.minutes <= finish
      slots << current
      current += SLOT_MINUTES.minutes
    end
    slots
  end
end
