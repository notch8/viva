# frozen_string_literal: true
class Feedback < ApplicationRecord
  belongs_to :user
  belongs_to :question

  # content validation to match frontend
  validates :content, presence: true
  validate :content_not_blank

  private

  def content_not_blank
    if content.present? && content.strip.blank?
      errors.add(:content, "can't be only whitespace")
    end
  end
end
