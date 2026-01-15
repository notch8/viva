# frozen_string_literal: true

# Devise authentication for users
class User < ApplicationRecord
  validates :email, presence: true, format: Devise.email_regexp
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_questions, through: :bookmarks, source: :question
  has_many :questions, dependent: :restrict_with_error

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    'Your account is not active. Please contact support.'
  end

  def role
    admin? ? 'Admin' : 'User'
  end

  def questions_exported_count
    ExportLogger.where(user_id: id).count
  end
end
