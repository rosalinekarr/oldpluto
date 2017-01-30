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

  def filters
    author_tags = author_ids.map{ |id| "author_#{id.parameterize}" }
    source_tags = source_ids.map{ |id| "source_#{id.parameterize}" }
    {
      tagFilters: author_tags + source_tags,
      numericFilters: (hours_ago ? ["age>#{hours_ago * 60}"] : []),
      replica: sort,
      hitsPerPage: Kaminari.config.default_per_page,
      page: page
    }
  end

  def sort
    @sort ||= ['popular', 'newest'].find{ |sort| sort == params[:sort] }
  end

  def page
    @page ||= params[:page].try(:to_i) || 1
  end
end
