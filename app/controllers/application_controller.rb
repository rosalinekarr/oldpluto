class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def page
    @page ||= params[:page].try(:to_i) || 1
  end
end
