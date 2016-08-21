class LinksController < ApplicationController
  def index
    @links = Link.all

    if params[:related_to].present?
      @related_link = Link.find(params[:related_to])
      @links = @related_link.find_related_tags
    end

    if params[:feed].present?
      @feed = Feed.friendly.find(params[:feed])
      @links = @links.where(feed: @feed)
    end

    @params = params.permit(:feed, :related_to)
    @links = @links.order(published_at: :desc).page params[:page]
  end
end
