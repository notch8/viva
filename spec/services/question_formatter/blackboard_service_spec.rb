# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionFormatter::BlackboardService do
  subject { described_class.new(question) }

  let(:file_lines) do
    Rails.root.join('spec', 'fixtures', 'files', 'bb_export.txt').readlines.map(&:chomp)
  end

  describe '#format_content' do
    context 'when it is traditional (multiple choice)' do
      let(:question) do
        Question::Traditional.new(
          text: 'Which anime series features a young boy named Izuku Midoriya who dreams of becoming a superhero?',
          data: [
            { 'answer' => 'My Hero Academia', 'correct' => true },
            { 'answer' => 'Naruto', 'correct' => false },
            { 'answer' => 'One Piece', 'correct' => false },
            { 'answer' => 'Attack on Titan', 'correct' => false }
          ]
        )
      end

      it 'returns the correct text' do
        expect(subject.format_content).to eq(file_lines[0])
      end
    end

    context 'when it is SATA' do
      let(:question) do
        Question::SelectAllThatApply.new(
          text: 'Which of the following anime studios produced films directed by Hayao Miyazaki?',
          data: [
            { 'answer' => 'Studio Ghibli', 'correct' => true },
            { 'answer' => 'Kyoto Animation', 'correct' => false },
            { 'answer' => 'Toei Animation', 'correct' => false },
            { 'answer' => 'Studio Ponoc', 'correct' => true },
            { 'answer' => 'Madhouse', 'correct' => false }
          ]
        )
      end

      it 'returns the correct text' do
        expect(subject.format_content).to eq(file_lines[1])
      end
    end

    context 'when it is Essay' do
      let(:question) do
        Question::Essay.new(
          text: 'Themes of friendship and perseverance',
          data: { 'html' => "<div class=\"question-introduction\">\n  <p>Analyze how themes of friendship are portrayed in shonen anime.</p>\n<p>Include specific examples from the series.</p></div>" }
        )
      end

      it 'returns the correct text' do
        expect(subject.format_content).to eq(file_lines[2])
      end
    end

    context 'when it is Matching' do
      let(:question) do
        Question::Matching.new(
          text: 'Match each anime character to their respective series',
          data: [
            { 'answer' => 'Spike Spiegel', 'correct' => ['Cowboy Bebop'] },
            { 'answer' => 'Mikasa Ackerman', 'correct' => ['Attack on Titan'] },
            { 'answer' => 'Edward Elric', 'correct' => ['Fullmetal Alchemist'] },
            { 'answer' => 'Master Roshi', 'correct' => ['Dragon Ball'] }
          ]
        )
      end

      it 'returns the correct text' do
        expect(subject.format_content).to eq(file_lines[3])
      end
    end

    context 'when blacboard export type is not supported' do
      let(:question) { FactoryBot.build(:question_upload) }

      it 'returns nil' do
        expect(question.blackboard_export_type).to be_nil
        expect(subject.format_content).to be_nil
      end
    end
  end
end
