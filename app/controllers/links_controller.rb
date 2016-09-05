class LinksController < ApplicationController
  def index
    @links = Link.includes(:feed, :tags)

    @links = @links.tagged_with(tag)    if tag.present?
    @links = @links.where(feed: source) if source.present?

    if sort.present?
      @links = @links.order({ sort => sort_direction })
    else
      @links = @links.order('visits / extract (\'epoch\' from (current_timestamp - published_at)) DESC, published_at DESC')
    end
    @links = @links.page page
  end

  def show
    @link = Link.find(params[:id])
    @link.update(visits: @link.visits + 1)
    redirect_to @link.url
  end

  def share
    @link = Link.find(params[:link_id])
    @link.update(shares: @link.shares + 1)
    if params[:network] == 'facebook'
      redirect_to "https://www.facebook.com/sharer.php?u=#{ERB::Util.url_encode @link.url}"
    elsif params[:network] == 'twitter'
      redirect_to "https://twitter.com/intent/tweet?url=#{ERB::Util.url_encode @link.url}"
    elsif params[:network] == 'google'
      redirect_to "https://plus.google.com/share?url=#{ERB::Util.url_encode @link.url}"
    elsif params[:network] == 'reddit'
      redirect_to "https://www.reddit.com/submit?url=#{ERB::Util.url_encode @link.url}"
    elsif params[:network] == 'tumblr'
      redirect_to "https://www.tumblr.com/widgets/share/tool?canonicalUrl=#{ERB::Util.url_encode @link.url}"
    elsif params[:network] == 'pinterest'
      redirect_to "https://pinterest.com/pin/create/bookmarklet/?url=#{ERB::Util.url_encode @link.url}"
    elsif params[:network] == 'linkedin'
      redirect_to "https://www.linkedin.com/shareArticle?url=#{ERB::Util.url_encode @link.url}"
    elsif params[:network] == 'buffer'
      redirect_to "https://buffer.com/add?url=#{ERB::Util.url_encode @link.url}"
    elsif params[:network] == 'digg'
      redirect_to "http://digg.com/submit?url=#{ERB::Util.url_encode @link.url}"
    elsif params[:network] == 'stumbleupon'
      redirect_to "http://www.stumbleupon.com/submit?url=#{ERB::Util.url_encode @link.url}"
    elsif params[:network] == 'delicious'
      redirect_to "https://delicious.com/save?v=5&url=#{ERB::Util.url_encode @link.url}"
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  private

  def tag
    @tag ||= params[:tag]
  end

  def source
    @source ||= Feed.friendly.find(params[:source]) if params[:source].present?
  end

  def page
    @page ||= params[:page] || 1
  end

  def sort
    @sort ||= params[:sort]
  end

  def sort_direction
    @direction ||= params[:direction] || 'desc'
  end
end
