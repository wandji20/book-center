require 'rails_helper'

RSpec.describe "Books Search", type: :request do
  let!(:book1) { create(:book, title: 'Ruby on Rails Tutorial', author: 'Michael Hartl') }
  let!(:book2) { create(:book, title: 'Clean Code', author: 'Robert Martin') }
  let!(:book3) { create(:book, title: 'Design Patterns in Ruby', author: 'Russ Olsen') }

  describe "GET /" do
    context "without search query" do
      it "returns all books" do
        get root_path
        expect(response).to be_successful
        expect(response.body).to include(book1.title)
        expect(response.body).to include(book2.title)
        expect(response.body).to include(book3.title)
      end
    end

    context "with search query" do
      it "returns matching books by title" do
        get root_path, params: { query: 'Clean' }
        expect(response).to be_successful
        expect(response.body).to include(book2.title)
        expect(response.body).not_to include(book1.title)
        expect(response.body).not_to include(book3.title)
      end

      it "returns matching books by author" do
        get root_path, params: { query: 'Hartl' }
        expect(response).to be_successful
        expect(response.body).to include(book1.title)
        expect(response.body).not_to include(book2.title)
        expect(response.body).not_to include(book3.title)
      end

      it "is case insensitive" do
        get root_path, params: { query: 'rUbY' }
        expect(response).to be_successful
        expect(response.body).to include(book1.title)
        expect(response.body).to include(book3.title)
        expect(response.body).not_to include(book2.title)
      end

      it "shows no results message when no matches found" do
        get root_path, params: { query: 'Nonexistent' }
        expect(response).to be_successful
        expect(response.body).to include("No books found!")
        expect(response.body).not_to include(book1.title)
        expect(response.body).not_to include(book2.title)
        expect(response.body).not_to include(book3.title)
      end

      it "handles empty query string" do
        get root_path, params: { query: '   ' }
        expect(response).to be_successful
        expect(response.body).to include(book1.title)
        expect(response.body).to include(book2.title)
        expect(response.body).to include(book3.title)
      end
    end
  end

  describe "search analytics job" do
    it "enqueues search job for new queries" do
      expect {
        get root_path, params: { query: 'New Query' }
      }.to have_enqueued_job(ManageSearchQueryJob)
    end
  
    it "doesn't enqueue job for repeated queries" do
      get root_path, params: { query: 'Repeated' }
      expect {
        get root_path, params: { query: 'Repeated' }
      }.not_to have_enqueued_job(ManageSearchQueryJob)
    end
  end
end