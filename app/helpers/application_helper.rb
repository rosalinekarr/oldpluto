module ApplicationHelper
  def author_path(author_id)
    author_ids = (params[:authors] || []) + [author_id.parameterize]
    url_for(path_params.merge(authors: author_ids.uniq))
  end

  def source_path(source_id)
    source_ids = (params[:sources] || []) + [source_id.parameterize]
    url_for(path_params.merge(sources: source_ids.uniq))
  end

  def remove_author_path(author_id)
    author_ids = (params[:authors] || []) - [author_id]
    url_for(path_params.merge(authors: author_ids))
  end

  def remove_source_path(source_id)
    source_ids = (params[:sources] || []) - [source_id]
    url_for(path_params.merge(sources: source_ids))
  end

  private

  def path_params
    params.permit(:hours_ago, :q, :sort, authors: [], sources: [])
  end
end
