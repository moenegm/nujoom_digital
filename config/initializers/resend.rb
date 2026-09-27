# Custom ActionMailer delivery method for Resend (https://resend.com), used
# instead of SMTP because our host blocks outbound SMTP ports (587/465) —
# a normal SMTP relay (including Resend's own) would hit the same block.
# This talks to Resend's HTTPS API directly via the `resend` gem's
# Resend::Emails.send, so it isn't tied to a specific ActionMailer
# integration shipping with that gem.
Resend.api_key = Rails.application.credentials.dig(:resend, :api_key)

class ResendDeliveryMethod
  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    Resend::Emails.send(build_payload(mail))
  end

  private

  def build_payload(mail)
    payload = {
      "from" => mail[:from].formatted.first,
      "to" => mail[:to].formatted,
      "subject" => mail.subject
    }

    payload["cc"] = mail[:cc].formatted if mail[:cc]
    payload["bcc"] = mail[:bcc].formatted if mail[:bcc]
    payload["reply_to"] = mail[:reply_to].formatted.first if mail[:reply_to]

    if mail.multipart?
      html_part = mail.html_part
      text_part = mail.text_part
      payload["html"] = html_part.decoded if html_part
      payload["text"] = text_part.decoded if text_part
    elsif mail.content_type.to_s.include?("html")
      payload["html"] = mail.decoded
    else
      payload["text"] = mail.decoded
    end

    attachments = build_attachments(mail)
    payload["attachments"] = attachments if attachments.present?

    payload
  end

  def build_attachments(mail)
    mail.attachments.map do |attachment|
      {
        "filename" => attachment.filename,
        "content" => Base64.strict_encode64(attachment.body.decoded)
      }
    end
  end
end

ActionMailer::Base.add_delivery_method :resend, ResendDeliveryMethod
