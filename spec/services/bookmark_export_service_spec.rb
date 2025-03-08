# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarkExportService do
  let(:user) { build_stubbed(:user) }
  let(:question1) { build_stubbed(:question_traditional) }
  let(:question2) { build_stubbed(:question_essay) }
  let(:bookmark1) { build_stubbed(:bookmark, user:, question: question1) }
  let(:bookmark2) { build_stubbed(:bookmark, user:, question: question2) }
  let(:bookmarks) { [bookmark1, bookmark2] }
  let(:service) { described_class.new(bookmarks) }

  describe '#initialize' do
    it 'sets bookmarks and questions' do
      expect(service.bookmarks).to eq(bookmarks)
      expect(service.questions).to match_array([question1, question2])
    end
  end

  describe '#export' do
    it 'calls the appropriate export method based on format' do
      expect(service).to receive(:text_export)
      service.export('txt')

      expect(service).to receive(:markdown_export)
      service.export('md')

      expect(service).to receive(:xml_export)
      service.export('xml')

      expect(service).to receive(:canvas_export)
      service.export('canvas')

      expect(service).to receive(:blackboard_export)
      service.export('blackboard')

      expect(service).to receive(:brightspace_export)
      service.export('brightspace')

      expect(service).to receive(:moodle_export)
      service.export('moodle_xml')
    end
  end

  describe 'export formats' do
    describe '#text_export' do
      it 'returns a hash with text data' do
        allow(BookmarkExporter).to receive(:as_text).and_return('text content')
        result = service.send(:text_export)

        expect(result[:data]).to eq('text content')
        expect(result[:filename]).to match(/questions-.*\.txt/)
        expect(result[:type]).to eq('text/plain')
        expect(result[:is_file]).to be false
      end
    end

    describe '#markdown_export' do
      it 'returns a hash with markdown data' do
        allow(BookmarkExporter).to receive(:as_markdown).and_return('markdown content')
        result = service.send(:markdown_export)

        expect(result[:data]).to eq('markdown content')
        expect(result[:filename]).to match(/questions-.*\.md/)
        expect(result[:type]).to eq('text/plain')
        expect(result[:is_file]).to be false
      end
    end

    describe '#xml_export' do
      context 'when questions have no images' do
        before do
          allow(question1).to receive(:images).and_return([])
          allow(question2).to receive(:images).and_return([])
        end

        it 'returns a hash with XML data' do
          allow(BookmarkExporter).to receive(:as_xml).and_return('<xml>content</xml>')
          result = service.send(:xml_export)

          expect(result[:data]).to eq('<xml>content</xml>')
          expect(result[:filename]).to match(/questions-.*\.xml/)
          expect(result[:type]).to eq('application/xml; charset=utf-8')
          expect(result[:is_file]).to be false
        end
      end

      context 'when questions have images' do
        let(:image) { double('Image') }
        let(:question_with_images) { build_stubbed(:question_traditional) }
        let(:bookmark_with_images) { build_stubbed(:bookmark, user:, question: question_with_images) }
        let(:service_with_images) { described_class.new([bookmark_with_images]) }

        before do
          allow(question_with_images).to receive(:images).and_return([image])
          allow(service_with_images).to receive(:questions).and_return([question_with_images])
        end

        it 'returns a hash with a zip file' do
          allow(BookmarkExporter).to receive(:as_xml).and_return('<xml>content</xml>')

          temp_file = Tempfile.new(['test', '.zip'])
          zip_service = instance_double(ZipFileService)
          allow(ZipFileService).to receive(:new).and_return(zip_service)
          allow(zip_service).to receive(:generate_zip).and_return(temp_file)

          result = service_with_images.send(:xml_export)

          expect(result[:data]).to eq(temp_file)
          expect(result[:filename]).to match(/questions-.*\.zip/)
          expect(result[:type]).to eq('application/zip')
          expect(result[:is_file]).to be true
        end
      end
    end

    describe '#canvas_export' do
      context 'when result is a string' do
        it 'returns a hash with XML data' do
          allow(BookmarkExporter).to receive(:as_canvas).and_return('<xml>canvas content</xml>')
          result = service.send(:canvas_export)

          expect(result[:data]).to eq('<xml>canvas content</xml>')
          expect(result[:filename]).to match(/questions-.*\.classic-question-canvas\.qti\.xml/)
          expect(result[:type]).to eq('application/xml')
          expect(result[:is_file]).to be_nil
        end
      end

      context 'when result is a tempfile' do
        it 'returns a hash with a zip file' do
          temp_file = Tempfile.new(['test', '.zip'])
          allow(BookmarkExporter).to receive(:as_canvas).and_return(temp_file)

          result = service.send(:canvas_export)

          expect(result[:data]).to eq(temp_file)
          expect(result[:filename]).to match(/questions-.*\.classic-question-canvas\.qti\.zip/)
          expect(result[:type]).to eq('application/zip')
          expect(result[:is_file]).to be true
        end
      end
    end

    describe '#blackboard_export' do
      it 'returns a hash with blackboard data' do
        allow(BookmarkExporter).to receive(:as_blackboard).and_return('blackboard content')
        result = service.send(:blackboard_export)

        expect(result[:data]).to eq('blackboard content')
        expect(result[:filename]).to eq('blackboard_export.txt')
        expect(result[:type]).to eq('text/plain')
      end
    end

    describe '#brightspace_export' do
      it 'returns a hash with brightspace data' do
        allow(BookmarkExporter).to receive(:as_brightspace).and_return('brightspace content')
        result = service.send(:brightspace_export)

        expect(result[:data]).to eq('brightspace content')
        expect(result[:filename]).to eq('brightspace_export.csv')
        expect(result[:type]).to eq('text/csv')
      end
    end

    describe '#moodle_export' do
      it 'returns a hash with moodle data' do
        allow(BookmarkExporter).to receive(:as_moodle).and_return('<xml>moodle content</xml>')
        result = service.send(:moodle_export)

        expect(result[:data]).to eq('<xml>moodle content</xml>')
        expect(result[:filename]).to eq('moodle_export.xml')
        expect(result[:type]).to eq('application/xml')
      end
    end
  end
end
