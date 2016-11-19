class AdvertisementsController < ApplicationController
  before_action :authenticate_user!

  def new
    @advertisement = Advertisement.new
  end

  def create
    @advertisement = current_user.advertisements.new(advertisement_params)
    if @advertisement.save
      redirect_to root_path, notice: 'Your ad has been submitted for approval.'
    else
      render 'new'
    end
  end

  private

  def advertisement_params
    params.require(:advertisement).permit(:title, :url)
  end
end
