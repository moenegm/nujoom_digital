class AdminController < ApplicationController
  layout "admin"

  before_action :authenticate_admin!

  private

  # Simple HTTP Basic Auth gate for the whole /admin section. There's only
  # one provider using this site (Mohamed), so a single shared username +
  # password — stored in Rails credentials, not the database — is enough.
  # The browser handles the login prompt itself; nothing to build.
  def authenticate_admin!
    authenticate_or_request_with_http_basic("Nujoom Digital Admin") do |username, password|
      configured_username = Rails.application.credentials.dig(:admin, :username).to_s
      configured_password = Rails.application.credentials.dig(:admin, :password).to_s

      next false if configured_username.blank? || configured_password.blank?

      ActiveSupport::SecurityUtils.secure_compare(username, configured_username) &
        ActiveSupport::SecurityUtils.secure_compare(password, configured_password)
    end
  end

  # Single-provider site — this is always Nujoom Digital's own calendar.
  def current_provider
    @current_provider ||= Provider.first!
  end
end
