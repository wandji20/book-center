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

  def analytics
    user = User.find_or_create_by(ip_address: request.remote_ip)

    @trending_data= Search.trending.map{ |s| [ s.query, s.search_count ] }
    @searches_data= user.searches.group(:query).count
  end

  private

  def process_query(query)
    last_query = session[:last_query] || ''
    session[:last_query] = query

    return unless query.present?
    return if last_query == query

    ManageSearchQueryJob.perform_later(request.remote_ip, last_query, query.downcase)
  end
end