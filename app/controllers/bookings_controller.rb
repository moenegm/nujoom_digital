class BookingsController < ApplicationController
  # This is a single-provider site right now — Nujoom Digital's own booking
  # calendar — so we always book against this one provider record.
  PROVIDER_EMAIL = "mr.negm90@gmail.com"

  # GET /available_slots
  # Returns the next several open business days for the provider, with each
  # slot marked available or already booked.
  def available_slots
    provider = current_provider
    days = provider.open_days(count: 6)

    payload = days.map do |date|
      slots = provider.slots_on(date)
      taken_at = provider.bookings.where(starts_at: slots).pluck(:starts_at).to_set

      {
        date: date.iso8601,
        label: I18n.l(date, format: :day_picker),
        slots: slots.map do |slot|
          {
            time: slot.strftime("%H:%M"),
            label: I18n.l(slot, format: :slot),
            available: !taken_at.include?(slot)
          }
        end
      }
    end

    render json: { days: payload }
  end

  # POST /bookings
  # Creates a booking for a specific date + time. Relies on the model
  # validation *and* the database's unique index on (provider_id, starts_at)
  # as a second line of defense against two people booking the same slot
  # at the same moment.
  def create
    provider = current_provider
    starts_at = parse_starts_at

    if starts_at.nil?
      return render json: { status: "error", errors: [ "That time slot isn't valid." ] }, status: :unprocessable_entity
    end

    booking = provider.bookings.new(
      client_name: params[:name],
      client_email: params[:email],
      note: params[:note],
      starts_at: starts_at,
      ends_at: starts_at + Provider::SLOT_MINUTES.minutes
    )

    if booking.save
      send_booking_emails(booking)
      render json: { status: "ok", starts_at: booking.starts_at.iso8601 }, status: :created
    else
      render json: { status: "error", errors: booking.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    # Belt-and-suspenders: if two requests race past the model validation,
    # the DB's unique index catches it here.
    render json: { status: "error", errors: [ "That slot was just booked by someone else." ] }, status: :conflict
  end

  private

  def send_booking_emails(booking)
    BookingMailer.confirmation(booking).deliver_later
    BookingMailer.provider_notification(booking).deliver_later

    day_before_time = booking.starts_at - 24.hours
    if day_before_time > Time.current
      BookingReminderJob.set(wait_until: day_before_time).perform_later(booking.id, "day_before")
    end

    morning_of_time = booking.starts_at.in_time_zone.change(hour: 8, min: 0)
    if morning_of_time > Time.current && morning_of_time < booking.starts_at
      BookingReminderJob.set(wait_until: morning_of_time).perform_later(booking.id, "morning_of")
    end
  end

  def current_provider
    Provider.find_by!(email: PROVIDER_EMAIL)
  end

  def parse_starts_at
    return nil if params[:date].blank? || params[:time].blank?

    Time.zone.parse("#{params[:date]} #{params[:time]}")
  rescue ArgumentError
    nil
  end
end
