class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :confirmable, :database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :advertisements, dependent: :destroy

  has_many :favorites, dependent: :destroy
  has_many :links,     through: :favorites

  has_many :clicks
  has_many :shares
end
