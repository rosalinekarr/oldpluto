class LinksController < ApplicationController
  def index
    @links = Link.includes(:feed)

    if params[:tag].present?
      @links = @links.tagged_with(params[:tag])
    end

    if params[:feed].present?
      @feed = Feed.friendly.find(params[:feed])
      @links = @links.where(feed: @feed)
    end

    @params = params.permit(:feed, :tag)
    @links = @links.order(published_at: :desc).page params[:page]
  end

  def show
    @link = Link.find(params[:id])
    @link.update(visits: @link.visits + 1)
    redirect_to @link.url
  end
end
