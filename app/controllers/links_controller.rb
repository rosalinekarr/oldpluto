class LinksController < ApplicationController
  def index
    @links = Link.order(:created_at).page params[:page]
  end
end
