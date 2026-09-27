module Admin
  class AvailabilitiesController < AdminController
    def index
      @availabilities = current_provider.availabilities.order(:day_of_week, :start_time)
      @availability = current_provider.availabilities.new
    end

    def create
      @availability = current_provider.availabilities.new(availability_params)

      if @availability.save
        redirect_to admin_availabilities_path, notice: "Availability window added."
      else
        @availabilities = current_provider.availabilities.order(:day_of_week, :start_time)
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      current_provider.availabilities.find(params[:id]).destroy
      redirect_to admin_availabilities_path, notice: "Availability window removed."
    end

    private

    def availability_params
      params.require(:availability).permit(:day_of_week, :start_time, :end_time)
    end
  end
end
