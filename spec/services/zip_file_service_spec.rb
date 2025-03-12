# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZipFileService do
  describe '#generate_zip' do
    it 'creates a zip file with the xml content and images' do
      question = create(:question_bow_tie, :with_images)
      temp_file = described_class.new(question.images, 'xml content', 'filename.xml', 'questions').generate_zip

      Zip::File.open(temp_file.path) do |zipfile|
        expect(zipfile.entries.map(&:name)).to include('questions/filename.xml')
        expect(zipfile.entries.map(&:name)).to include("questions/images/#{question.images.first.file.filename}")
      end
    end
  end
end
