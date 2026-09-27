class BookingReminderJob < ApplicationJob
  queue_as :default

  # If the booking got deleted before this job ran (shouldn't happen yet,
  # since there's no cancellation feature — but this keeps it from erroring).
  discard_on ActiveJob::DeserializationError

  def perform(booking_id, timing)
    booking = Booking.find_by(id: booking_id)
    return unless booking

    BookingMailer.reminder(booking, timing).deliver_now
  end
end
