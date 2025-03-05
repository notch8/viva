# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormatter::MoodleService do
  subject { described_class.new(questions) }

  # rubocop:disable Layout/LineLength
  let(:questions) do
    [
      Question::Essay.new(
        text: 'Ethical Considerations in End-of-Life Care',
        data: {
          'html' =>
            "<div class=\"question-introduction\">\n  <h3>Nursing Ethics in End-of-Life Care</h3>\n\n  <p><strong>Describe the ethical dilemma in this scenario and explain how you would approach this situation as the patient's nurse. Include in your discussion:</strong></p>\n  <ul>\n    <li>The key ethical principles involved</li>\n    <li>Your role as patient advocate</li>\n  </ul>\n\n  <p>Support your response with specific references to the nursing code of ethics and current best practices in end-of-life care.</p>\n</div>\n"
        }
      )
    ]
  end
  # rubocop:enable Layout/LineLength

  before do
    uploaded_file_1 = fixture_file_upload('spec/fixtures/files/cat-injured.jpg', 'image/jpeg')
    img_1 = question.images.build
    img_1.file.attach(uploaded_file_1)
    img_1.alt_text = ('injured cat')
    img_1.save!

    uploaded_file_2 = fixture_file_upload('spec/fixtures/files/dog-injured.jpg', 'image/jpeg')
    img_2 = question.images.build
    img_2.file.attach(uploaded_file_2)
    img_2.alt_text = ('injured dog')
    img_2.save!

    allow(question).to receive(:subjects).and_return(
      [
        instance_double(Subject, name: 'Engineering'),
        instance_double(Subject, name: 'History')
      ]
    )
  end

  describe '#format_content' do
    context 'when it is Essay' do
      let(:question) { questions.find { |question| question.is_a? Question::Essay } }
      let(:fixture) { 'spec/fixtures/files/moodle_essay.xml' }

      it 'returns the correct xml' do
        expect(subject.format_content).to eq File.read(fixture)
      end
    end
  end
end
