# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarkExporter do
  let(:traditional_question) { create(:question_traditional, text: "What is Ruby?") }
  let(:essay_question) { create(:question_essay, text: "Explain Rails architecture.") }
  let(:questions) { [traditional_question, essay_question] }
  
  describe '.as_text' do
    it 'formats questions as plain text' do
      expect(QuestionFormatter::PlainTextService).to receive(:new).with(traditional_question).and_call_original
      expect(QuestionFormatter::PlainTextService).to receive(:new).with(essay_question).and_call_original
      
      result = described_class.as_text(questions)
      
      expect(result).to include("What is Ruby?")
      expect(result).to include("Explain Rails architecture.")
      expect(result).to be_a(String)
    end
  end
  
  describe '.as_markdown' do
    it 'formats questions as markdown' do
      expect(QuestionFormatter::MarkdownService).to receive(:new).with(traditional_question).and_call_original
      expect(QuestionFormatter::MarkdownService).to receive(:new).with(essay_question).and_call_original
      
      result = described_class.as_markdown(questions)
      
      expect(result).to include("What is Ruby?")
      expect(result).to include("Explain Rails architecture.")
      expect(result).to be_a(String)
    end
  end
  
  describe '.as_xml' do
    it 'renders the bookmarks/export template' do
      expect(ApplicationController).to receive(:render).with(
        hash_including(
          template: 'bookmarks/export',
          assigns: hash_including(questions: questions)
        )
      ).and_return("<xml>test</xml>")
      
      result = described_class.as_xml(questions)
      expect(result).to eq("<xml>test</xml>")
    end
  end
  
  describe '.as_canvas' do
    context 'when questions have no images' do
      it 'returns XML content' do
        expect(ApplicationController).to receive(:render).with(
          hash_including(
            template: 'bookmarks/export',
            assigns: hash_including(questions: questions)
          )
        ).and_return("<xml>canvas test</xml>")
        
        result = described_class.as_canvas(questions)
        expect(result).to eq("<xml>canvas test</xml>")
      end
    end
    
    context 'when questions have images' do
      let(:question_with_images) { create(:question_traditional, :with_images) }
      let(:questions_with_images) { [question_with_images] }
      
      it 'returns a zip file' do
        expect(ApplicationController).to receive(:render).and_return("<xml>canvas with images</xml>")
        
        temp_file = Tempfile.new(['test', '.zip'])
        expect_any_instance_of(ZipFileService).to receive(:generate_zip).and_return(temp_file)
        
        result = described_class.as_canvas(questions_with_images)
        expect(result).to be_a(Tempfile)
      end
    end
  end
  
  describe '.as_blackboard' do
    it 'formats questions for Blackboard' do
      expect(QuestionFormatter::BlackboardService).to receive(:new).with(traditional_question).and_call_original
      expect(QuestionFormatter::BlackboardService).to receive(:new).with(essay_question).and_call_original
      
      result = described_class.as_blackboard(questions)
      expect(result).to be_a(String)
    end
  end
  
  describe '.as_brightspace' do
    it 'returns a message that the format is not implemented' do
      result = described_class.as_brightspace(questions)
      expect(result).to eq("BrightSpace export format is not implemented yet.")
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
  
  describe '.generate_zip_file' do
    it 'creates a zip file with content for the specified format' do
      expect(described_class).to receive(:generate_content_for_format).with(questions, 'canvas').and_return("<xml>canvas</xml>")
      
      temp_file = Tempfile.new(['test', '.zip'])
      expect_any_instance_of(ZipFileService).to receive(:generate_zip).and_return(temp_file)
      
      result = described_class.generate_zip_file(questions, 'canvas')
      expect(result).to be_a(Tempfile)
    end
  end
  
  describe '.generate_content_for_format' do
    it 'generates content for canvas format' do
      expect(ApplicationController).to receive(:render).and_return("<xml>canvas</xml>")
      
      result = described_class.generate_content_for_format(questions, 'canvas')
      expect(result).to eq("<xml>canvas</xml>")
    end
    
    it 'generates content for blackboard format' do
      expect(QuestionFormatter::BlackboardService).to receive(:new).twice.and_call_original
      
      result = described_class.generate_content_for_format(questions, 'blackboard')
      expect(result).to be_a(String)
    end
    
    it 'generates content for brightspace format' do
      result = described_class.generate_content_for_format(questions, 'brightspace')
      expect(result).to eq("BrightSpace export format is not implemented yet.")
    end
    
    it 'generates content for moodle format' do
      moodle_service = instance_double(QuestionFormatter::MoodleService)
      expect(QuestionFormatter::MoodleService).to receive(:new).with(questions).and_return(moodle_service)
      expect(moodle_service).to receive(:format_content).and_return("<moodle>content</moodle>")
      
      result = described_class.generate_content_for_format(questions, 'moodle')
      expect(result).to eq("<moodle>content</moodle>")
    end
  end
end