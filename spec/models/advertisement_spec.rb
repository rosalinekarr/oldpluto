require 'rails_helper'

RSpec.describe Advertisement, type: :model do
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }

  describe '#approve' do
    it 'sets the approved_at timestamp' do
      ad = create :advertisement
      ad.approve
      expect(ad.approved_at).not_to be_nil
    end
  end

  describe '#approved?' do
    it 'returns true if the approved_at timestamp is set' do
      ad = create :advertisement, approved_at: DateTime.now
      expect(ad.approved?).to be_truthy
    end

    it 'returns false if the approved_at timestamp is not set' do
      ad = create :advertisement
      expect(ad.approved?).to be_falsey
    end
  end
end
