require 'rails_helper'

RSpec.describe Search, type: :model do
  subject { create(:search) }

  it { should validate_presence_of(:query) }
  it { should belong_to(:user) }
end
