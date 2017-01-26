class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @links = current_user.links.includes(:author, :feed)
                               .since(hours_ago)
                               .from_feeds(source_ids)
                               .authored_by(author_ids)
                               .references(:author, :feed)
                               .order(sort)
                               .page page
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
