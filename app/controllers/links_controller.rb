class LinksController < ApplicationController
  def index
    @links = Link.includes(:author, :feed).search(params[:q], filters)
    CreateImpressionJob.perform_later(current_user.try(:id), @links.map(&:id))
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
