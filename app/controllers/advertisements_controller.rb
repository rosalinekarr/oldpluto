class AdvertisementsController < ApplicationController
  def new
    @advertisement = Advertisement.new
  end

  def create
    @advertisement = Advertisement.new(advertisement_params)
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
