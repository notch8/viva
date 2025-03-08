# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormatter::D2lService do
  let(:essay_question) do
    build(:question_essay,
      text: 'Sample essay question',
      data: { 'html' => '<p>Essay prompt</p><ul><li>Point 1</li></ul><a href="https://example.com">Link</a>' })
  end
  let(:formatted_essay_question) do
    "NewQuestion,WR\nID,\nTitle,Sample essay question\nQuestionText,\"<p>Essay prompt</p><ul><li>Point 1</li></ul><a href=\"\"https://example.com\"\">Link</a>\",HTML\n"
  end
  let(:matching_question) do
    build(:question_matching,
      text: 'Sample matching question',
      data: [
        {
          'answer' => 'Term 1',
          'correct' => ['Definition 1']
        },
        {
          'answer' => 'Term 2',
          'correct' => ['Definition 2']
        },
        {
          'answer' => 'Term 3',
          'correct' => ['Definition 3']
        }
      ])
  end
  let(:formatted_matching_question) do
    "NewQuestion,M\nID,\nQuestionText,Sample matching question\nChoice,1,Term 1\nChoice,2,Term 2\nChoice,3,Term 3\nMatch,1,Definition 1\nMatch,2,Definition 2\nMatch,3,Definition 3\n"
  end
  let(:select_all_question) do
    build(:question_select_all_that_apply,
      text: 'Sample select all question',
      data: [
        { 'answer' => 'Option A', 'correct' => true },
        { 'answer' => 'Option B', 'correct' => true },
        { 'answer' => 'Option C', 'correct' => false }
      ])
  end
  let(:formatted_select_all_question) do
    "NewQuestion,MS\nID,\nQuestionText,Sample select all question\nOption,100,Option A\nOption,100,Option B\nOption,0,Option C\n"
  end
  let(:traditional_question) do
    build(:question_traditional,
      text: 'Sample multiple choice',
      data: [
        { 'answer' => 'Option A', 'correct' => true },
        { 'answer' => 'Option B', 'correct' => false }
      ])
  end
  let(:formatted_traditional_question) do
    "NewQuestion,MC\nID,\nQuestionText,Sample multiple choice\nOption,100,Option A\nOption,0,Option B\n"
  end

  let(:upload_question) do
    build(:question_upload,
      text: 'Sample upload question',
      data: { 'html' => '<p>Upload instructions</p><ul><li>File type: PDF</li></ul><a href="https://example.com">Guidelines</a>' })
  end
  let(:formatted_upload_question) do
    "NewQuestion,WR\nID,\nTitle,Sample upload question\nQuestionText,\"<p>Upload instructions</p><ul><li>File type: PDF</li></ul><a href=\"\"https://example.com\"\">Guidelines</a>\",HTML\n"
  end

  let(:unsupported_question) do
    build(:question_categorization,
      text: 'Sample categorization',
      data: [
        { 'answer' => 'Category 1', 'correct' => ['Item 1', 'Item 2'] },
        { 'answer' => 'Category 2', 'correct' => ['Item 3'] }
      ])
  end

  describe '#format_content' do
    it 'handles essays' do
      expect(described_class.new([essay_question]).format_content).to eq(formatted_essay_question)
      expect(described_class.new([essay_question]).format_content).to be_a(String)
    end

    it 'handles matching' do
      expect(described_class.new([matching_question]).format_content).to eq(formatted_matching_question)
    end

    it 'handles select all that apply' do
      expect(described_class.new([select_all_question]).format_content).to eq(formatted_select_all_question)
    end

    it 'handles traditional' do
      expect(described_class.new([traditional_question]).format_content).to eq(formatted_traditional_question)
    end

    it 'handles uploads' do
      expect(described_class.new([upload_question]).format_content).to eq(formatted_upload_question)
    end

    it 'does not handle other types' do
      expect(described_class.new([unsupported_question]).format_content).to be_blank
    end
  end

  describe 'with images' do
    let(:image) { double(:image, url: "/rails/active_storage/blobs/cat-injured.jpg") }

    before do
      allow(traditional_question).to receive(:images).and_return([image])
    end

    it 'includes the image URL' do
      expect(described_class.new([traditional_question]).format_content).to include(image.url)
    end
  end
end
