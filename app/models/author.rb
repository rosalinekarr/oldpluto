class Author < ApplicationRecord
  has_many :links, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: true
end
