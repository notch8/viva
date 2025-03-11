# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormatter::CanvasService do
  describe '#format_content' do
    context 'with images' do
      let!(:question) { create(:question_essay, :with_images) }
      let(:manifest) { Rails.root.join('spec', 'fixtures', 'files', 'imsmanifest.xml').read }

      it 'produces a manifest file' do
        expect(described_class.new([question]).generate_manifest).to eq(manifest)
      end
  end
end
