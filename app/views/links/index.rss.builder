title = 'Rising News'
title = 'Popular News' if params[:sort] == 'popular'
title = 'Latest News'  if params[:sort] == 'newest'

xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title "Old Pluto | #{title}"
    xml.link links_path
    xml.language 'en'

    for link in @links
      xml.item do
        xml.title link.title
        xml.author link.author.name if link.author.present?
        xml.pubDate link.published_at.to_s(:rfc822)
        xml.link link.url
        xml.guid link.guid
        xml.description link.body
      end
    end
  end
end
