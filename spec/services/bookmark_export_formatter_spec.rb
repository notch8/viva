# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarkExportFormatter do
  let(:traditional_question) { build_stubbed(:question_traditional, text: "What is Ruby?") }
  let(:essay_question) { build_stubbed(:question_essay, text: "Explain Rails architecture.") }
  let(:questions) { [traditional_question, essay_question] }

  describe '.as_text' do
    it 'formats questions as plain text' do
      text_service1 = instance_double(QuestionFormatter::PlainTextService, format_content: "What is Ruby? (formatted)")
      text_service2 = instance_double(QuestionFormatter::PlainTextService, format_content: "Explain Rails architecture. (formatted)")

      expect(QuestionFormatter::PlainTextService).to receive(:new).with(traditional_question).and_return(text_service1)
      expect(QuestionFormatter::PlainTextService).to receive(:new).with(essay_question).and_return(text_service2)

      result = described_class.as_text(questions)

      expect(result).to include("What is Ruby? (formatted)")
      expect(result).to include("Explain Rails architecture. (formatted)")
    end
  end

  describe '.as_markdown' do
    it 'formats questions as markdown' do
      md_service1 = instance_double(QuestionFormatter::MarkdownService, format_content: "# What is Ruby?")
      md_service2 = instance_double(QuestionFormatter::MarkdownService, format_content: "# Explain Rails architecture.")

      expect(QuestionFormatter::MarkdownService).to receive(:new).with(traditional_question).and_return(md_service1)
      expect(QuestionFormatter::MarkdownService).to receive(:new).with(essay_question).and_return(md_service2)

      result = described_class.as_markdown(questions)

      expect(result).to include("# What is Ruby?")
      expect(result).to include("# Explain Rails architecture.")
    end
  end

  describe '.as_xml' do
    it 'renders the bookmarks/export template' do
      expect(ApplicationController).to receive(:render).with(
        hash_including(
          template: 'bookmarks/export',
          assigns: hash_including(questions:)
        )
      ).and_return("<xml>test</xml>")

      result = described_class.as_xml(questions)
      expect(result).to eq("<xml>test</xml>")
    end
  end

  describe '.as_canvas' do
    context 'when questions have no images' do
      before do
        allow(traditional_question).to receive(:images).and_return([])
        allow(essay_question).to receive(:images).and_return([])
      end

      it 'returns XML content' do
        expect(ApplicationController).to receive(:render).with(
          hash_including(
            template: 'bookmarks/export',
            assigns: hash_including(questions:)
          )
        ).and_return("<xml>canvas test</xml>")

        result = described_class.as_canvas(questions)
        expect(result).to eq("<xml>canvas test</xml>")
      end
    end

    context 'when questions have images' do
      let(:image) { double('Image') }
      let(:question_with_images) { build_stubbed(:question_traditional) }

      before do
        allow(question_with_images).to receive(:images).and_return([image])
        allow(questions).to receive(:any?).and_return(true)
        allow(questions).to receive(:flat_map).and_return([image])
      end

      it 'returns a zip file' do
        expect(ApplicationController).to receive(:render).and_return("<xml>canvas with images</xml>")

        temp_file = Tempfile.new(['test', '.zip'])
        zip_service = instance_double(ZipFileService)
        expect(ZipFileService).to receive(:new).and_return(zip_service)
        expect(zip_service).to receive(:generate_zip).and_return(temp_file)

        result = described_class.as_canvas(questions)
        expect(result).to be_a(Tempfile)
      end
    end
  end

  describe '.as_blackboard' do
    it 'formats questions for Blackboard' do
      bb_service1 = instance_double(QuestionFormatter::BlackboardService, format_content: "BB: What is Ruby?")
      bb_service2 = instance_double(QuestionFormatter::BlackboardService, format_content: "BB: Explain Rails architecture.")

      expect(QuestionFormatter::BlackboardService).to receive(:new).with(traditional_question).and_return(bb_service1)
      expect(QuestionFormatter::BlackboardService).to receive(:new).with(essay_question).and_return(bb_service2)

      result = described_class.as_blackboard(questions)
      expect(result).to eq("BB: What is Ruby?\n\nBB: Explain Rails architecture.")
    end
  end

  describe '.as_brightspace' do
    it 'uses D2lService to format questions' do
      brightspace_service = instance_double(QuestionFormatter::D2lService)
      expect(QuestionFormatter::D2lService).to receive(:new).with(questions).and_return(brightspace_service)
      expect(brightspace_service).to receive(:format_content).and_return("brightspace content")

      result = described_class.as_brightspace(questions)
      expect(result).to eq("brightspace content")
    end
  end

  describe '.as_moodle' do
    it 'uses MoodleService to format questions' do
      moodle_service = instance_double(QuestionFormatter::MoodleService)
      expect(QuestionFormatter::MoodleService).to receive(:new).with(questions).and_return(moodle_service)
      expect(moodle_service).to receive(:format_content).and_return("<moodle>content</moodle>")

      result = described_class.as_moodle(questions)
      expect(result).to eq("<moodle>content</moodle>")
    end
  end
end
