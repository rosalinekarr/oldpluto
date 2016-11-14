require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:clicks) }
  it { is_expected.to have_many(:impressions) }
  it { is_expected.to have_many(:shares) }
end
