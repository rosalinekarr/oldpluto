class Impression < ApplicationRecord
  belongs_to :user
  belongs_to :link
end
