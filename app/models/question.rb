# frozen_string_literal: true

class Question < ApplicationRecord
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :keywords
  validates :text, presence: true
end
