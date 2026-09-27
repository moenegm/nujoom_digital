class ContactMailer < ApplicationMailer
  RECIPIENT = "mr.negm90@gmail.com"

  def inquiry(name:, email:, message:)
    @name = name
    @email = email
    @message = message

    mail(
      to: RECIPIENT,
      reply_to: email,
      subject: "New project inquiry from #{name}"
    )
  end
end
