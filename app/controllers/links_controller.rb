class LinksController < ApplicationController
  def index
    query = Link.includes(:feed, :tags)
                .where('tags.taggings_count > 1')
                .references(:tags)

    query = query.where('links.title LIKE ? OR links.body LIKE ?', q, q) if q.present?
    query = query.tagged_with(tags)   if tags.any?
    query = query.where(feed: source) if source.present?

    query = query.order(sort)
    @links = query.page page
    @links.each do |link|
      Impression.create user: current_user, link: link
    end
  end

  def show
    @link = Link.find(params[:id])
    Click.create user: current_user, link: @link
    redirect_to @link.url
  end

  def share
    @share = Share.new user: current_user,
                       link_id: params[:link_id],
                       network: params[:network]
    if @share.save
      redirect_to @share.url
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  private

  def q
    @q ||= params[:q].present? ? "%#{params[:q]}%" : nil
  end

  def tags
    @tags ||= params[:tags] || []
  end

  def source
    @source ||= Feed.friendly.find(params[:source]) if params[:source].present?
  end

  def page
    @page ||= params[:page] || 1
  end

  def sort
    @sort ||= begin
      if params[:sort] == 'popular'
        'shares_count + clicks_count desc'
      elsif params[:sort] == 'rising'
        '1.0 + shares_count + clicks_count / extract (\'epoch\' from (current_timestamp - published_at)) desc'
      elsif params[:sort] == 'newest'
        'published_at desc'
      else
        '(shares_count + clicks_count) / (1.0 + impressions_count + feeds.links_count) desc'
      end
    end
  end
end
