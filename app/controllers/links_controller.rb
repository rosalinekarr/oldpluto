class LinksController < ApplicationController
  def index
    @links = Link.includes(:feed)

    @links = @links.tagged_with(params[:tag])       if params[:tag].present?
    @links = @links.where(feed_id: params[:source]) if params[:source].present?

    authenticate_user! if page != 1

    @params = params.permit(:direction, :feed, :sort, :tag)
    @links = @links.order({ sort => sort_direction }).page page
  end

  def show
    @link = Link.find(params[:id])
    @link.update(visits: @link.visits + 1)
    redirect_to @link.url
  end

  private

  def page
    @page ||= params[:page] || 1
  end

  def sort
    @sort ||= params[:sort].try(:to_sym) || :published_at
  end

  def sort_direction
    @direction ||= params[:direction].try(:to_sym) || :desc
  end
end
