class LinksController < ApplicationController
  before_action :set_advertisement, only: [:index]

  def index
    @links = Link.search(params[:q], filters)
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
end
