class Tag < ApplicationRecord
  before_save :update_score

  private

  def update_score
    self.score = clicks / (count + 1.0) if clicks_changed? || count_changed?
  end
end
