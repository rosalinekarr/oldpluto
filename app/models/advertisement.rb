class Advertisement < ApplicationRecord
  validates :title, presence: true
  validates :url,   presence: true

  def approve
    update(approved_at: DateTime.now) unless approved?
  end

  def approved?
    approved_at.present?
  end
end
