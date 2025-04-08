require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }

  it { should validate_presence_of(:ip_address) }
  it { should validate_uniqueness_of(:ip_address) }
  it { should have_many(:searches) }
end
