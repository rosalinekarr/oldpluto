class Advertisement < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :url,   presence: true

  scope :approved, -> { where('approved_at IS NOT NULL') }

  def approve
    update(approved_at: DateTime.now) unless approved?
  end

  def approved?
    approved_at.present?
  end
end
