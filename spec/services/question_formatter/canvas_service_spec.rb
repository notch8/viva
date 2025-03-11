# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormatter::CanvasService do
  subject { described_class.new([question]).format_content }

  describe '#format_content' do
    context 'with images' do
      let!(:question) { create(:question_essay, :with_images) }
      let(:manifest) { Rails.root.join('spec', 'fixtures', 'files', 'imsmanifest.xml').read }

      it 'produces a manifest file' do
        expect(
          Zip::File.open(subject) do |zip|
            zip.get_input_stream('imsmanifest.xml').read
          end
        ).to eq(manifest)
      end
    end
  end
end
