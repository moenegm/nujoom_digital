class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  around_action :switch_locale

  private

  # English/Arabic toggle for the public site. A `?locale=ar` link sets it
  # and it's remembered in the session from then on (including for the
  # /available_slots fetch call, so day/time labels come back translated
  # too — the fetch request carries the same session cookie).
  def switch_locale(&action)
    if params[:locale].present? && I18n.available_locales.map(&:to_s).include?(params[:locale])
      session[:locale] = params[:locale]
    end

    I18n.with_locale(session[:locale] || I18n.default_locale, &action)
  end
end
