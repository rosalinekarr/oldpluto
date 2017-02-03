require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:favorites) }
  it { is_expected.to have_many(:links).through(:favorites) }

  it { is_expected.to have_many(:clicks) }
  it { is_expected.to have_many(:shares) }
end
