class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :confirmable, :database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
