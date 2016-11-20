class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    query = current_user.links.includes(:author, :feed, :tags)

    query = query.where('published_at > ?', hours_ago.hours.ago) if hours_ago.present?
    query = query.tagged_with(tags) if tags.any?
    query = query.where(feeds:   { slug: source_ids }) if source_ids.any?
    query = query.where(authors: { slug: author_ids }) if author_ids.any?

    query = query.order sort
    @favorites = query.page page
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
