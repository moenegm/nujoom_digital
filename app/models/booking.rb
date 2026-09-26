class Booking < ApplicationRecord
  belongs_to :provider

  validates :client_name, :client_email, presence: true
  validates :starts_at, :ends_at, presence: true
  validates :starts_at, uniqueness: { scope: :provider_id, message: "is already booked for this provider" }
end
