class ManageSearchQueryJob < ApplicationJob
  queue_as :default

  def perform(ip_address, query)
    user = User.find_or_create_by(ip_address: ip_address)

    last_search = user.searches.last

    unless last_search.present? # When is user first search
      user.searches.create(query: query)
      return
    end

    case true
    when query.starts_with?(last_search.query)
      last_search.update(query: query)
    else
      user.searches.create(query: query)
    end
  end
end
