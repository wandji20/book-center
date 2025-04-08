class ManageSearchQueryJob < ApplicationJob
  queue_as :default

  def perform(ip_address, last_query, query)
    user = User.find_or_create_by(ip_address: ip_address)

    last_search = user.searches.last

    unless last_search.present? # When is user first search
      user.searches.create(query: query)
      return
    end

    case true
    when last_query.empty? # if search query was cleared
      user.searches.create(query: query)
    when query.starts_with?(last_search.query) # if last search query is included in query
      last_search.update(query: query)
    else
      user.searches.create(query: query)
    end
  end
end
