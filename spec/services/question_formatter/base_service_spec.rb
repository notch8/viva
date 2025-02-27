# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormatter::BaseService do
  let(:subject) { described_class.new(question) }
  let(:question) do
    build(:question_essay,
      text: 'Sample essay question',
      data: { 'html' => '<p>Essay prompt</p><ul><li>Point 1</li></ul><a href="https://example.com">Link</a>' })
  end

  it 'has the correct public methods' do
    expect(subject).to respond_to(:format_content)
  end

  context 'when calling #format_content' do
    describe 'when question model has no valid model_exporter method defined' do
      before do
        allow(question.class).to receive(:model_exporter).and_return('abc')
        allow(subject).to receive(:divider_line).and_return("\n---\n\n")
      end

      it 'handles errors gracefully' do
        expect(subject.format_content).to eq("Question type: Essay requires a valid export format method\n---\n\n")
      end
    end
  end
end
