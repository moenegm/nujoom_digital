module Admin
  class BookingsController < AdminController
    def index
      @upcoming = current_provider.bookings.where("starts_at >= ?", Time.current).order(:starts_at)
      @past = current_provider.bookings.where("starts_at < ?", Time.current).order(starts_at: :desc).limit(20)
    end

    def new
      @booking = current_provider.bookings.new
    end

    def create
      @booking = current_provider.bookings.new(booking_params)
      @booking.ends_at = @booking.starts_at + Provider::SLOT_MINUTES.minutes if @booking.starts_at

      if @booking.save
        redirect_to admin_bookings_path, notice: "Booking added for #{@booking.client_name}."
      else
        render :new, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique
      @booking.errors.add(:starts_at, "is already booked")
      render :new, status: :unprocessable_entity
    end

    def edit
      @booking = current_provider.bookings.find(params[:id])
    end

    def update
      @booking = current_provider.bookings.find(params[:id])
      @booking.assign_attributes(booking_params)
      @booking.ends_at = @booking.starts_at + Provider::SLOT_MINUTES.minutes if @booking.starts_at

      if @booking.save
        redirect_to admin_bookings_path, notice: "Booking updated."
      else
        render :edit, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique
      @booking.errors.add(:starts_at, "is already booked")
      render :edit, status: :unprocessable_entity
    end

    def destroy
      @booking = current_provider.bookings.find(params[:id])
      BookingMailer.cancellation(@booking).deliver_later
      @booking.destroy
      redirect_to admin_bookings_path, notice: "Booking cancelled — the client has been emailed."
    end

    private

    def booking_params
      params.require(:booking).permit(:client_name, :client_email, :note, :starts_at)
    end
  end
end
