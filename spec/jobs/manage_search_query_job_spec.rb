require 'rails_helper'

RSpec.describe ManageSearchQueryJob, type: :job do
  let(:user) { create(:user) }
  
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform' do
    context 'when user has no previous searches' do
      it 'creates a new search record' do
        expect {
          described_class.perform_now(user.ip_address, '', 'ruby')
        }.to change(Search, :count).by(1)
      end

      it 'associates the search with the correct user' do
        described_class.perform_now(user.ip_address, '', 'rails')
        expect(user.searches.last.query).to eq('rails')
      end
    end

    context 'when new query extends previous query' do
      before { user.searches.create(query: 'ruby') }

      it 'updates the existing search record' do
        expect {
          described_class.perform_now(user.ip_address, 'ruby', 'ruby on rails')
        }.to change(Search, :count).by(0)
      end

      it 'extends the query' do
        described_class.perform_now(user.ip_address, 'ruby', 'ruby on rails')
        expect(user.searches.last.query).to eq('ruby on rails')
      end
    end

    context 'when new query is completely different' do
      before { user.searches.create(query: 'python') }

      it 'creates a new search record' do
        expect {
          described_class.perform_now(user.ip_address, 'python', 'javascript')
        }.to change(Search, :count).by(1)
      end

      it 'preserves the previous search' do
        described_class.perform_now(user.ip_address, 'python', 'javascript')
        expect(user.searches.pluck(:query)).to eq(['python', 'javascript'])
      end
    end

    context 'when user does not exist' do
      it 'creates a new user' do
        new_ip = '192.168.1.2'
        expect {
          described_class.perform_now(new_ip, '', 'go')
        }.to change(User, :count).by(1)
      end
    end
  end
end