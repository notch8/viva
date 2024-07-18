# frozen_string_literal: true

# Devise authentication for users
class User < ApplicationRecord
  validates :email, presence: true, format: Devise.email_regexp
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_questions, through: :bookmarks, source: :question
end
