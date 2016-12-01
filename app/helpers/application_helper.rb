module ApplicationHelper
  def tag_path(tag)
    query = [params[:q], tag].compact.join(' ')
    url_for(path_params.merge(q: query))
  end

  private

  def path_params
    params.permit(:authors, :hours_ago, :q, :sort, :sources)
  end
end
