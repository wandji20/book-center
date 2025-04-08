class HomeController < ApplicationController
  def books
    query = params[:query].strip
    @books = if query.present?
      q_string = "%#{Book.sanitize_sql_like(query)}%"
      Book.where("title ILIKE ? OR author ILIKE ?", q_string, q_string)
    else
      Book.all
    end

    @books.order(:title, :author)
  end
end