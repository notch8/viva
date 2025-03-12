# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarkExportService do
  let(:user) { build_stubbed(:user) }
  let(:question1) { build_stubbed(:question_traditional, text: "What is Ruby?") }
  let(:question2) { build_stubbed(:question_essay, text: "Explain Rails architecture.") }
  let(:bookmark1) { build_stubbed(:bookmark, user:, question: question1) }
  let(:bookmark2) { build_stubbed(:bookmark, user:, question: question2) }
  let(:bookmarks) { [bookmark1, bookmark2] }
  let(:questions) { [question1, question2] }
  let(:service) { described_class.new(bookmarks) }

  describe '#initialize' do
    it 'sets bookmarks and questions' do
      expect(service.bookmarks).to eq(bookmarks)
      expect(service.questions).to match_array([question1, question2])
    end
  end

  describe '#export' do
    it 'calls the appropriate export method dynamically based on format' do
      expect(service).to receive(:send).with('txt_export', anything)
      service.export('txt')

      expect(service).to receive(:send).with('md_export', anything)
      service.export('md')

      expect(service).to receive(:send).with('canvas_export', anything)
      service.export('canvas')

      expect(service).to receive(:send).with('blackboard_export', anything)
      service.export('blackboard')

      expect(service).to receive(:send).with('d2l_export', anything)
      service.export('d2l')

      expect(service).to receive(:send).with('moodle_export', anything)
      service.export('moodle')
    end
  end

  describe 'export formats' do
    describe '#txt_export' do
      let(:formatter_klass) { QuestionFormatter::PlainTextService }

      before do
        allow_any_instance_of(formatter_klass).to receive(:format_content).and_return('text content')
      end

      it 'returns a hash with text data' do
        result = service.export('txt')

        expect(result[:data]).to eq('text content')
        expect(result[:filename]).to match(/questions-txt.*\.txt/)
        expect(result[:type]).to eq('text/plain')
        expect(result[:is_file]).to be false
      end
    end

    describe '#md_export' do
      let(:formatter_klass) { QuestionFormatter::MarkdownService }

      before do
        allow_any_instance_of(formatter_klass).to receive(:format_content).and_return('markdown content')
      end

      it 'returns a hash with markdown data' do
        result = service.export('md')

        expect(result[:data]).to eq('markdown content')
        expect(result[:filename]).to match(/questions-md.*\.md/)
        expect(result[:type]).to eq('text/plain')
        expect(result[:is_file]).to be false
      end
    end

    describe '#canvas_export' do
      let(:formatter_klass) { QuestionFormatter::CanvasService }
      let(:xml_content) { '<xml>content</xml>' }

      before do
        allow(ApplicationController).to receive(:render).and_return(xml_content)
      end

      context 'when questions have no images' do
        before do
          allow(question1).to receive(:images).and_return([])
          allow(question2).to receive(:images).and_return([])
        end

        it 'returns a hash with XML data' do
          result = service.export('canvas')

          expect(result[:filename]).to match(/questions-canvas.*\.zip/)
          expect(result[:type]).to eq('application/zip')
          expect(result[:is_file]).to be true
        end
      end

      context 'when questions have images' do
        let(:image) { double('Image') }
        let(:images) { double('ActiveRecord::Associations::CollectionProxy', any?: true) }
        let(:question_with_images) { build_stubbed(:question_traditional) }
        let(:bookmark_with_images) { build_stubbed(:bookmark, user:, question: question_with_images) }
        let(:service_with_images) { described_class.new([bookmark_with_images]) }
        let(:temp_file) { Tempfile.new(['test', '.zip']) }
        let(:zip_service) { instance_double(ZipFileService) }

        before do
          allow(question_with_images).to receive(:images).and_return(images)
          # allow(images).to receive(:any?).and_return(true)
          allow(ZipFileService).to receive(:new).and_return(zip_service)
          allow(zip_service).to receive(:generate_zip).and_return(temp_file)
        end

        it 'returns a hash with a zip file' do
          result = service_with_images.export('canvas')

          expect(result[:data]).to eq(temp_file)
          expect(result[:filename]).to match(/questions-canvas.*\.zip/)
          expect(result[:type]).to eq('application/zip')
          expect(result[:is_file]).to be true
        end
      end
    end

    describe '#blackboard_export' do
      let(:formatter_klass) { QuestionFormatter::BlackboardService }

      before do
        allow_any_instance_of(formatter_klass).to receive(:format_content).and_return('blackboard content')
      end

      it 'returns a hash with blackboard data' do
        result = service.export('blackboard')

        expect(result[:data]).to eq('blackboard content')
        expect(result[:filename]).to match(/questions-blackboard.*\.txt/)
        expect(result[:type]).to eq('text/plain')
      end
    end

    describe '#d2l_export' do
      let(:formatter_klass) { QuestionFormatter::D2lService }

      before do
        allow_any_instance_of(formatter_klass).to receive(:format_content).and_return('brightspace content')
      end

      it 'returns a hash with brightspace data' do
        result = service.export('d2l')

        expect(result[:data]).to eq('brightspace content')
        expect(result[:filename]).to match(/questions-d2l.*\.zip/)
        expect(result[:type]).to eq('application/zip')
      end
    end

    describe '#moodle_export' do
      let(:formatter_klass) { QuestionFormatter::MoodleService }

      before do
        allow_any_instance_of(formatter_klass).to receive(:format_content).and_return('<xml>moodle content</xml>')
      end

      it 'returns a hash with brightspace data' do
        result = service.export('moodle')

        expect(result[:data]).to eq('<xml>moodle content</xml>')
        expect(result[:filename]).to match(/questions-moodle.*\.xml/)
        expect(result[:type]).to eq('application/xml')
      end
    end
  end
end
