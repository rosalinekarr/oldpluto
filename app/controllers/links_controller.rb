class LinksController < ApplicationController
  def index
    if params[:tag].present?
      @links = Link.tagged_with(params[:tag])
    else
      @links = Link.all
    end

    if params[:feed].present?
      @feed = Feed.friendly.find(params[:feed])
      @links = @links.where(feed: @feed)
    end

    @params = params.permit(:feed, :tag)
    @links = @links.order(published_at: :desc).page params[:page]
  end
end
