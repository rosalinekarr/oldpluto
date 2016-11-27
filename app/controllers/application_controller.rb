class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def hours_ago
    @hours_ago ||= params[:hours_ago].to_i if params[:hours_ago].present?
  end

  def source_ids
    @source_ids ||= params[:sources] || []
  end

  def author_ids
    @author_ids ||= params[:authors] || []
  end

  def sort
    @sort ||= begin
      if params[:sort] == 'popular'
        'shares_count + clicks_count desc'
      elsif params[:sort] == 'newest'
        'published_at desc'
      elsif params[:sort] == 'trending'
        'score / (impressions_count + 1.0) desc'
      else
        '(shares_count + clicks_count) * 3600.0 / extract (\'epoch\' from (current_timestamp - published_at)) desc'
      end
    end
  end

  def page
    @page ||= params[:page].try(:to_i) || 1
  end
end
