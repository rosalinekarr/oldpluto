class LinksController < ApplicationController
  def index
    @links = Link.all

    if params[:feed].present?
      @feed = Feed.friendly.find(params[:feed])
      @links = @links.where(feed: @feed)
    end

    @links = @links.order(created_at: :desc).page params[:page]
  end
end
