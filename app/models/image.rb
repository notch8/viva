# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :question
  has_one_attached :file

  validates :file, presence: true

  def url
    Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
  end
end
