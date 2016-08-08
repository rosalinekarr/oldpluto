class LinksController < ApplicationController
  def index
    if params[:feed_id].present?
      @feed = Feed.friendly.find(params[:feed_id])
      @links = @feed.links.order(created_at: :desc).page params[:page]
    else
      @links = Link.order(created_at: :desc).page params[:page]
    end
  end
end
