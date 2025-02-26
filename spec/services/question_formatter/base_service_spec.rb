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
end
