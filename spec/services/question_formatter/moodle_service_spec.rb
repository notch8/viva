# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormatter::MoodleService do
  subject { described_class.new(questions) }

  # rubocop:disable Layout/LineLength
  let(:user) { create(:user) }
  let(:questions) do
    [
      Question::Essay.new(
        text: 'Ethical Considerations in End-of-Life Care',
        user_id: user.id,
        data: {
          'html' =>
            "<div class=\"question-introduction\">\n  <h3>Nursing Ethics in End-of-Life Care</h3>\n\n  <p><strong>Describe the ethical dilemma in this scenario and explain how you would approach this situation as the patient's nurse. Include in your discussion:</strong></p>\n  <ul>\n    <li>The key ethical principles involved</li>\n    <li>Your role as patient advocate</li>\n  </ul>\n\n  <p>Support your response with specific references to the nursing code of ethics and current best practices in end-of-life care.</p>\n</div>\n"
        }
      ),
      Question::Matching.new(
        text: 'Match each medication to its appropriate nursing consideration:',
        user_id: user.id,
        data: [
          { 'answer' => 'Digoxin', 'correct' => ['Monitor for bradycardia and dysrhythmias'] },
          { 'answer' => 'Furosemide', 'correct' => ['Monitor for electrolyte imbalances and dehydration'] },
          { 'answer' => 'Warfarin', 'correct' => ['Monitor for bleeding and check INR levels'] },
          { 'answer' => 'Metformin', 'correct' => ['Monitor for lactic acidosis and check renal function'] },
          { 'answer' => 'Levothyroxine', 'correct' => ['Monitor for signs of hyperthyroidism and check TSH levels'] }
        ]
      ),
      Question::Traditional.new(
        text: 'A nurse is administering IV vancomycin to a patient. Twenty minutes into the infusion, the patient develops a diffuse erythematous rash on the face, neck, and upper torso, accompanied by hypotension with BP 90/50 mmHg. What is the priority nursing action?',
        user_id: user.id,
        data: [
          { 'answer' => 'Stop the medication immediately and notify the physician', 'correct' => true },
          { 'answer' => 'Continue administration at a slower rate and monitor vital signs', 'correct' => false },
          { 'answer' => 'Administer diphenhydramine as prescribed and continue the infusion', 'correct' => false },
          { 'answer' => 'Document the reaction and complete the scheduled dose', 'correct' => false }
        ]
      ),
      Question::SelectAllThatApply.new(
        text: 'A nurse is caring for a patient diagnosed with community-acquired pneumonia. Which nursing interventions are appropriate for this patient? Select all that apply.',
        user_id: user.id,
        data: [
          { 'answer' => 'Monitor vital signs every 2-4 hours', 'correct' => true },
          { 'answer' => 'Maintain head of bed elevation at 30-45 degrees', 'correct' => true },
          { 'answer' => 'Administer antibiotics as prescribed on time', 'correct' => true },
          { 'answer' => 'Restrict fluid intake to prevent pulmonary edema', 'correct' => false },
          { 'answer' => 'Place the patient in a supine position for lung expansion', 'correct' => false }
        ]
      )
    ]
  end
  # rubocop:enable Layout/LineLength

  describe '#format_content' do
    context 'when it is individual questions' do
      subject { described_class.new([question]) }

      before do
        allow(question).to receive(:subjects).and_return(
          [
            instance_double(Subject, name: 'Engineering'),
            instance_double(Subject, name: 'History')
          ]
        )
      end

      context 'when it is Essay (with two images)' do
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
        end

        subject { described_class.new([question]) }

        let(:question) { questions.find { |question| question.is_a? Question::Essay } }
        let(:fixture) { 'spec/fixtures/files/moodle_essay.xml' }

        it 'returns the correct xml' do
          expect(subject.format_content).to eq File.read(fixture)
        end
      end

      context 'when it is Matching' do
        let(:question) { questions.find { |question| question.is_a? Question::Matching } }
        let(:fixture) { 'spec/fixtures/files/moodle_matching.xml' }

        it 'returns the correct xml' do
          allow(question).to receive(:id).and_return(1)
          expect(subject.format_content).to eq File.read(fixture)
        end
      end

      context 'when it is Traditional' do
        let(:question) { questions.find { |question| question.is_a? Question::Traditional } }
        let(:fixture) { 'spec/fixtures/files/moodle_traditional.xml' }

        it 'returns the correct xml' do
          allow(question).to receive(:id).and_return(1)
          expect(subject.format_content).to eq File.read(fixture)
        end
      end

      context 'when it is SATA' do
        let(:question) { questions.find { |question| question.is_a? Question::SelectAllThatApply } }
        let(:fixture) { 'spec/fixtures/files/moodle_sata.xml' }

        it 'returns the correct xml' do
          allow(question).to receive(:id).and_return(1)
          expect(subject.format_content).to eq File.read(fixture)
        end
      end
    end

    context 'when it is multiple questions' do
      subject { described_class.new(questions) }
      let(:fixture) { 'spec/fixtures/files/moodle.xml' }

      it 'returns the correct xml' do
        expect(subject.format_content).to eq File.read(fixture)
      end
    end
  end
end
