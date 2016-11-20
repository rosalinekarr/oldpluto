class LinksController < ApplicationController
  before_action :set_advertisement, only: [:index]

  def index
    query = Link.includes(:author, :feed, :tags)

    query = query.where('links.title LIKE ? OR links.body LIKE ?', q, q) if q.present?
    query = query.where('published_at > ?', hours_ago.hours.ago) if hours_ago.present?
    query = query.tagged_with(tags) if tags.any?
    query = query.where(feeds:   { slug: source_ids }) if source_ids.any?
    query = query.where(authors: { slug: author_ids }) if author_ids.any?

    query = query.order sort
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

  def set_advertisement
    @advertisement = Advertisement.approved.order('RANDOM()').first if page == 1
  end

  def q
    @q ||= params[:q].present? ? "%#{params[:q]}%" : nil
  end
end
