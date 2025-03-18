# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormatter::CanvasService do
  subject { described_class.new([question]).format_content }
  let(:service) { described_class.new([question]) }

  describe '#format_content' do
    context 'with images' do
      let!(:question) { create(:question_essay, :with_images) }
      let(:fixture_xml) { Rails.root.join('spec', 'fixtures', 'files', 'imsmanifest.xml').read }

      it 'produces a manifest file' do
        generated_xml = Zip::File.open(subject) do |zip|
          zip.get_input_stream('imsmanifest.xml').read
        end

        # Use the service's pretty_xml! method to normalize both XMLs
        normalized_generated = service.send(:pretty_xml!, generated_xml)
        normalized_fixture = service.send(:pretty_xml!, fixture_xml)

        expect(normalized_generated).to eq(normalized_fixture)
      end
    end
  end
end
