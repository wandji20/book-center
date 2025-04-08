class HomeController < ApplicationController
  def books
    query = params[:query]&.strip
    process_query(query)
    @books = if query.present?
      q_string = "%#{Book.sanitize_sql_like(query)}%"
      Book.where("title ILIKE ? OR author ILIKE ?", q_string, q_string)
    else
      Book.all
    end

    @books.order(:title, :author)
  end

  private

  def process_query(query)
    return unless query.present?
    last_query = session[:last_query]
    return if last_query == query

    session[:last_query] = query
    ManageSearchQueryJob.perform_later(request.remote_ip, query)
  end
end