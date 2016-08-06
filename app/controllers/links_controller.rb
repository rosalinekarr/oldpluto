class LinksController < ApplicationController
  def index
    @links = Link.all
  end
end
