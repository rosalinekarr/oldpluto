class LinksController < ApplicationController
  def index
    @links = Link.all

    if params[:feed].present?
      @feed = Feed.friendly.find(params[:feed])
      @links = @links.where(feed: @feed)
    end

    if params[:tags].present? && params[:tags].any?
      @links = @links.tagged_with(params[:tags], all: true)
    end

    @params = params.permit(:feed, tags: [])
    @tags = @params[:tags] || []
    @links = @links.order(published_at: :desc).page params[:page]
  end
end
