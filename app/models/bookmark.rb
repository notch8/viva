# frozen_string_literal: true
class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :question

  def self.create_batch(question_ids:, user:)
    question_ids = question_ids.split(',')
    create_batch_from_ids(question_ids:, user:)
  end

  def self.create_batch_from_ids(question_ids:, user:)
    Array.wrap(question_ids).each do |question_id|
      bookmark = user.bookmarks.find_or_create_by(question_id:)
      return :error unless bookmark.save
    end
    :success
  end
end
