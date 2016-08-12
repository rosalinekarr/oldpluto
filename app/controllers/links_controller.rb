class LinksController < ApplicationController
  def index
    @links = Link.all

    if params[:feed].present?
      @feed = Feed.friendly.find(params[:feed])
      @links = @links.where(feed: @feed)
    end

    if params[:tag].present?
      @links = @links.tagged_with(params[:tag])
    end

    @params = params.permit(:feed, :tag)
    @links = @links.order(created_at: :desc).page params[:page]
  end
end
