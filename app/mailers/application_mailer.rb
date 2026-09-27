class ApplicationMailer < ActionMailer::Base
  # Resend requires sending "from" an address on a domain you've verified
  # with them (nujoomdigital.com) — a plain Gmail "from" address would be
  # rejected. Replies still land in the real inbox via reply_to, set per
  # mailer below where relevant.
  default from: "Nujoom Digital <hello@nujoomdigital.com>",
          reply_to: "mr.negm90@gmail.com"
  layout "mailer"
end
