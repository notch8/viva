# frozen_string_literal: true
class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :question

  def self.create_batch(question_ids:, user:)
    question_ids = question_ids.split(',')
    question_ids.each do |question_id|
      bookmark = user.bookmarks.find_or_create_by(question_id:)
      if !bookmark.save
        return :error
      end
    end
    return :success
  end
end
