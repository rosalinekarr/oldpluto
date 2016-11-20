class AdvertisementsController < ApplicationController
  before_action :authenticate_user!

  def index
    @advertisements = current_user.advertisements.page(page)
  end

  def new
    @advertisement = Advertisement.new
  end

  def create
    @advertisement = current_user.advertisements.new(advertisement_params)
    if @advertisement.save
      redirect_to advertisements_path, notice: 'Your ad has been submitted for approval.'
    else
      render 'new'
    end
  end

  def destroy
    @advertisement = current_user.advertisements.find(params[:id])
    @advertisement.destroy
    redirect_to advertisements_path, notice: 'The advertisement has been successfully deleted.'
  end

  private

  def advertisement_params
    params.require(:advertisement).permit(:title, :url)
  end
end
