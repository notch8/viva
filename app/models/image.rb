# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :question
  has_one_attached :file

  validates :file, presence: true

  def url
    Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
  end

  def original_filename
    file.blob.filename.to_s
  end

  def base64_encoded_data
    Base64.strict_encode64(file.download)
  end
end
