class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @links = current_user.links.search(params[:q], { tagFilters: tag_filters })
    render 'links/index'
  end

  def create
    @favorite = current_user.favorites.new favorite_params
    if @favorite.save
      redirect_to :back
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def destroy
    Favorite.find(params[:id]).destroy
    redirect_to :back
  end

  private

  def favorite_params
    params.require(:favorite).permit(:link_id)
  end
end
