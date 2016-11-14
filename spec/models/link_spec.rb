require 'rails_helper'

RSpec.describe Link, type: :model do
  it 'creates a UpdateLinkTagsJob after create' do
    expect{ create :link }.to change{
      Delayed::Job.where('handler LIKE ?', '%UpdateLinkTagsJob%').count
    }.by(1)
  end

  it 'creates a DestroyLinkJob after create' do
    expect{ create :link }.to change{
      Delayed::Job.where('handler LIKE ?', '%DestroyLinkJob%').count
    }.by(1)
  end

  describe 'sanitizes attributes' do
    it 'sanitizes html entities from the title' do
      link = build :link, title: 'Cats &amp; Dogs'
      link.valid?
      expect(link.title).to eq('Cats & Dogs')
    end

    it 'sanitizes html from the title' do
      link = build :link, title: '<p>Cats and Dogs</p>'
      link.valid?
      expect(link.title).to eq('Cats and Dogs')
    end

    it 'sanitizes html entities from the body' do
      link = build :link, body: 'Cats &amp; Dogs'
      link.valid?
      expect(link.body).to eq('Cats & Dogs')
    end

    it 'sanitizes html from the body' do
      link = build :link, body: '<p>Cats and Dogs</p>'
      link.valid?
      expect(link.body).to eq('Cats and Dogs')
    end
  end

  describe '#corpus' do
    it 'returns an array of words including the title' do
      link = create :link, title: 'testword'
      expect(link.corpus).to include('testword')
    end

    it 'returns an array of words including the body' do
      link = create :link, body: 'testword'
      expect(link.corpus).to include('testword')
    end
  end
end
