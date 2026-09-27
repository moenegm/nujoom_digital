class BookingMailer < ApplicationMailer
  # One persistent Google Meet room used for every call, for now.
  MEET_LINK = "https://meet.google.com/myz-zuwa-nbu"

  def confirmation(booking)
    @booking = booking
    @meet_link = MEET_LINK
    @formatted_time = format_time(booking)

    attachments["appointment.ics"] = {
      mime_type: "text/calendar; method=PUBLISH; charset=UTF-8",
      content: build_ics(booking)
    }

    mail(to: booking.client_email, subject: "You're booked — #{@formatted_time}")
  end

  # `timing` is either "day_before" or "morning_of" (a String, since it
  # crosses the ActiveJob serialization boundary).
  def reminder(booking, timing)
    @booking = booking
    @meet_link = MEET_LINK
    @formatted_time = format_time(booking)
    @timing = timing

    subject =
      if timing == "day_before"
        "Reminder: your call with Nujoom Digital is tomorrow"
      else
        "Reminder: your call with Nujoom Digital is today"
      end

    mail(to: booking.client_email, subject: subject)
  end

  private

  def format_time(booking)
    booking.starts_at.strftime("%A, %B %-d at %-I:%M %p") + " (Muscat time)"
  end

  def build_ics(booking)
    dtstamp = Time.current.utc.strftime("%Y%m%dT%H%M%SZ")
    dtstart = booking.starts_at.utc.strftime("%Y%m%dT%H%M%SZ")
    dtend = booking.ends_at.utc.strftime("%Y%m%dT%H%M%SZ")

    <<~ICS.gsub("\n", "\r\n")
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//Nujoom Digital//Booking//EN
      CALSCALE:GREGORIAN
      METHOD:PUBLISH
      BEGIN:VEVENT
      UID:booking-#{booking.id}@nujoomdigital.com
      DTSTAMP:#{dtstamp}
      DTSTART:#{dtstart}
      DTEND:#{dtend}
      SUMMARY:Call with Nujoom Digital
      DESCRIPTION:Video call link: #{MEET_LINK}
      LOCATION:#{MEET_LINK}
      STATUS:CONFIRMED
      END:VEVENT
      END:VCALENDAR
    ICS
  end
end
