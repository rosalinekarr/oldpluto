class LinksController < ApplicationController
  def index
    @links = Link.includes(:feed, :tags)

    @links = @links.tagged_with(tags)   if tags.any?
    @links = @links.where(feed: source) if source.present?

    @links = @links.order(sort)
    @links = @links.page page
  end

  def show
    @link = Link.find(params[:id])
    @link.increment!(:visits)
    redirect_to @link.url
  end

  def share
    @link = Link.find(params[:link_id])
    @link.increment!(:shares)
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
      if Link::VALID_SORTS.include?(params[:sort])
        params[:sort]
      else
        Link::DEFAULT_SORT
      end
    end
  end
end
