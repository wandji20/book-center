class HomeController < ApplicationController
  before_action :set_user_ip

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
    user = User.find_or_create_by(ip_address: @fake_ip)

    @trending_data = Rails.cache.fetch("trending_searches/data}", expires_in: 1.minutes) do
      Search.trending.map{ |s| [ s.query, s.search_count ] }
    end

    @searches_data = Rails.cache.fetch("user_searches/data}", expires_in: 1.minutes) do
      user.searches.group(:query).order('count_all DESC').count
    end
  end

  private

  def process_query(query)
    last_query = session[:last_query] || ''
    session[:last_query] = query

    return unless query.present?
    return if last_query == query

    ManageSearchQueryJob.perform_later(@fake_ip, last_query, query.downcase)
  end

  def set_user_ip
    # Use this hack due to issue with multiple ips in production.
    @fake_ip = session[:ip] || Digest::SHA256.hexdigest("#{Time.current.to_f * 1000}-#{request.user_agent}-#{request.remote_ip}")
    session[:ip] = @fake_ip
  end
end