class PagesController < ApplicationController
  def home
    response.headers['Referrer-Policy'] = 'no-referrer'
  end

  def legal
  end
end
