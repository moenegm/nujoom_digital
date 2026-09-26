class Provider < ApplicationRecord
  has_many :availabilities
  has_many :bookings

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
