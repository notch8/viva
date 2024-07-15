# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :question
  has_one_attached :file

  validates :file, presence: true
end
