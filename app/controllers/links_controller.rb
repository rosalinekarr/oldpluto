class LinksController < ApplicationController
  before_action :authenticate_user!, only: [:favorite, :favorites, :unfavorite]

  def index
    query = Link.includes(:author, :feed, :tags)

    query = query.where('links.title LIKE ? OR links.body LIKE ?', q, q) if q.present?
    query = query.where('published_at > ?', hours_ago.hours.ago) if hours_ago.present?
    query = query.tagged_with(tags) if tags.any?
    query = query.where(feeds:   { slug: source_ids }) if source_ids.any?
    query = query.where(authors: { slug: author_ids }) if author_ids.any?

    query = query.order(sort)
    @links = query.page page
    @links.each do |link|
      Impression.create user: current_user, link: link
    end

    @advertisement = Advertisement.approved.order('RANDOM()').first if page == 1
  end

  def favorites
    query = current_user.links.includes(:author, :feed, :tags)

    query = query.where('links.title LIKE ? OR links.body LIKE ?', q, q) if q.present?
    query = query.where('published_at > ?', hours_ago.hours.ago) if hours_ago.present?
    query = query.tagged_with(tags) if tags.any?
    query = query.where(feed:   { slug: source_ids }) if source_ids.any?
    query = query.where(author: { slug: author_ids }) if author_ids.any?

    query = query.order(sort)
    @links = query.page(page)
    render 'index'
  end

  def show
    @link = Link.find(params[:id])
    Click.create user: current_user, link: @link
    redirect_to @link.url
  end

  def share
    link = Link.find(params[:link_id])
    @share = Share.new user: current_user, link: link, network: params[:network]
    if @share.save
      redirect_to @share.url
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def favorite
    link = Link.find(params[:link_id])
    @favorite = Favorite.new user: current_user, link: link
    if @favorite.save
      redirect_to :back
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def unfavorite
    Favorite.where(user: current_user, link_id: params[:link_id]).destroy_all
    redirect_to :back
  end

  private

  def q
    @q ||= params[:q].present? ? "%#{params[:q]}%" : nil
  end

  def hours_ago
    @hours_ago ||= params[:hours_ago].to_i if params[:hours_ago].present?
  end

  def tags
    @tags ||= params[:tags] || []
  end

  def source_ids
    @source_ids ||= params[:sources] || []
  end

  def author_ids
    @author_ids ||= params[:authors] || []
  end

  def page
    @page ||= params[:page].try(:to_i) || 1
  end

  def sort
    @sort ||= begin
      if params[:sort] == 'popular'
        'shares_count + clicks_count desc'
      elsif params[:sort] == 'newest'
        'published_at desc'
      elsif params[:sort] == 'trending'
        'score / (impressions_count + 1.0) desc'
      else
        '(shares_count + clicks_count) * 3600.0 / extract (\'epoch\' from (current_timestamp - published_at)) desc'
      end
    end
  end
end
