class Share < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  validates :network, presence: true

  after_save :update_search_index

  def url
    if network == 'facebook'
      "https://www.facebook.com/sharer.php?u=#{ERB::Util.url_encode link.url}"
    elsif network == 'twitter'
      "https://twitter.com/intent/tweet?url=#{ERB::Util.url_encode link.url}"
    elsif network == 'google'
      "https://plus.google.com/share?url=#{ERB::Util.url_encode link.url}"
    elsif network == 'reddit'
      "https://www.reddit.com/submit?url=#{ERB::Util.url_encode link.url}"
    elsif network == 'tumblr'
      "https://www.tumblr.com/widgets/share/tool?canonicalUrl=#{ERB::Util.url_encode link.url}"
    elsif network == 'pinterest'
      "https://pinterest.com/pin/create/bookmarklet/?url=#{ERB::Util.url_encode link.url}"
    elsif network == 'linkedin'
      "https://www.linkedin.com/shareArticle?url=#{ERB::Util.url_encode link.url}"
    elsif network == 'buffer'
      "https://buffer.com/add?url=#{ERB::Util.url_encode link.url}"
    elsif network == 'digg'
      "http://digg.com/submit?url=#{ERB::Util.url_encode link.url}"
    elsif network == 'stumbleupon'
      "http://www.stumbleupon.com/submit?url=#{ERB::Util.url_encode link.url}"
    elsif network == 'delicious'
      "https://delicious.com/save?v=5&url=#{ERB::Util.url_encode link.url}"
    end
  end

  private

  def update_search_index
    Link.start_index_job(link)
  end
end
