class LinksController < ApplicationController
  def index
    @links = Link.search(params[:q], filters)
    @links.each{ |l| Impression.create link: l, user: current_user }
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
end
