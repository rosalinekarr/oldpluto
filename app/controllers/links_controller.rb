class LinksController < ApplicationController
  def index
    @links = Link.includes(:feed)

    @links = @links.tagged_with(params[:tag])       if params[:tag].present?
    @links = @links.where(feed_id: params[:source]) if params[:source].present?

    authenticate_user! if page != 1

    @params = params.permit(:feed, :tag)
    @links = @links.order(published_at: :desc).page page
  end

  def show
    @link = Link.find(params[:id])
    @link.update(visits: @link.visits + 1)
    redirect_to @link.url
  end

  private

  def page
    params[:page] || 1
  end
end
