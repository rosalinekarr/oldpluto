class LinksController < ApplicationController
  def index
    query = Link.includes(:feed, :tags)
                .where('tags.taggings_count > 1')
                .references(:tags)

    query = query.where('links.title LIKE ? OR links.body LIKE ?', q, q) if q.present?
    query = query.where('published_at > ?', hours_ago.hours.ago) if hours_ago.present?
    query = query.tagged_with(tags) if tags.any?
    query = query.where(feed: sources) if sources.any?
    query = query.where(author: authors) if authors.any?

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
    link = Link.find(params[:link_id])
    @share = Share.new user: current_user, link: link, network: params[:network]
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

  def hours_ago
    @hours_ago ||= params[:hours_ago].to_i if params[:hours_ago].present?
  end

  def tags
    @tags ||= params[:tags] || []
  end

  def sources
    @sources ||= Feed.where(slug: source_ids)
  end

  def source_ids
    @source_ids ||= params[:sources] || []
  end

  def authors
    @authors ||= Author.where(name: author_ids)
  end

  def author_ids
    @author_ids ||= params[:authors] || []
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
      else
        'published_at desc'
      end
    end
  end
end
