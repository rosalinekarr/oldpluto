require 'rails_helper'

RSpec.describe Feed, type: :model do
  describe '#fetch' do
    let(:entry) { double() }

    before do
      allow(entry).to receive(:title) { Faker::Lorem.word }
      allow(entry).to receive(:url)   { Faker::Internet.url }
      allow(Feedjira::Feed).to receive(:fetch_and_parse) { |url| [entry] }
    end

    it 'creates a link' do
      feed = create :feed
      expect{ feed.fetch }.to change{ Link.count }.by(1)
    end
  end
end
