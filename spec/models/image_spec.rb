# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Image, type: :model do
  let(:question) { create(:question_traditional, :with_images, images_count: 1) }
  let(:image) { question.images.first }

  describe 'associations' do
    it { should belong_to(:question) }
  end

  describe 'validations' do
    it { should validate_presence_of(:file) }
  end

  describe 'attaching a file' do
    it 'can attach a file to an image' do
      expect(image.file).to be_attached
    end
  end
end
