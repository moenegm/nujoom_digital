class ContactsController < ApplicationController
  def create
    name = params[:name].to_s.strip
    email = params[:email].to_s.strip
    message = params[:message].to_s.strip

    if name.blank? || message.blank? || !valid_email?(email)
      return render json: {
        status: "error",
        errors: [ "Please fill in all fields with a valid email." ]
      }, status: :unprocessable_entity
    end

    ContactMailer.inquiry(name: name, email: email, message: message).deliver_later

    render json: { status: "ok" }, status: :created
  end

  private

  def valid_email?(email)
    email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
  end
end
