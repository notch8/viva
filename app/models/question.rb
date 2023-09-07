# frozen_string_literal: true

class Question < ApplicationRecord
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :keywords
  validates :text, presence: true

  # Filter questions by filter and category
  def self.filter(keywords: [], categories: [])
    questions = Question.all
    # TODO: filter only when all keywords are a match
    questions = questions.where(id: Keyword.joins(:questions).where(name: keywords).pluck(:question_id)) if keywords.present?
    questions
  end
end
