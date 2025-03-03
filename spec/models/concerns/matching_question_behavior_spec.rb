# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MatchingQuestionBehavior do
  before(:all) do
    # Create a temporary class that includes our behavior
    class TestMatchingQuestion < ApplicationRecord
      self.table_name = 'questions' # Use the questions table
      include MatchingQuestionBehavior

      def qti_max_value
        100
      end
    end
  end

  after(:all) do
    # Clean up our temporary class
    Object.send(:remove_const, :TestMatchingQuestion)
  end

  describe '#build_qti_data' do
    let(:instance) { TestMatchingQuestion.new }

    context 'with duplicate choice text' do
      before do
        instance.data = [
          { 'answer' => 'Match 1', 'correct' => ['A', 'A'] },  # Intentionally duplicate
          { 'answer' => 'Match 2', 'correct' => ['B', 'A'] }   # 'A' appears again
        ]
      end

      it 'generates unique identifiers even for duplicate choice text' do
        instance.send(:build_qti_data)
        conditions = instance.qti_response_conditions

        expect(conditions[0].response.ident).not_to eq(conditions[1].response.ident)

        choice_idents = conditions.flat_map { |c| c.choices.map(&:ident) }

        # Verify all identifiers are unique
        expect(choice_idents.uniq).to eq(choice_idents)

        # Verify format of choice identifiers
        expect(choice_idents).to all(match(/^\d+$/))

        # Get all 'A' choices and their identifiers
        a_idents = conditions.flat_map do |condition|
          condition.choices.select { |c| c.text == 'A' }.map(&:ident)
        end

        # We should have 3 'A's with unique identifiers
        expect(a_idents.length).to eq(3)
        expect(a_idents.uniq.length).to eq(3)
      end

      it 'maintains correct text associations despite unique identifiers' do
        instance.send(:build_qti_data)
        conditions = instance.qti_response_conditions

        expect(conditions[0].choices.map(&:text)).to eq(['A', 'A'])
        expect(conditions[1].choices.map(&:text)).to eq(['B', 'A'])
      end

      it 'generates numeric identifiers in expected ranges' do
        instance.send(:build_qti_data)
        conditions = instance.qti_response_conditions

        # Choice IDs should be sequential numbers starting from 100
        choice_idents = conditions.flat_map { |c| c.choices.map(&:ident) }.map(&:to_i)
        expect(choice_idents.min).to be >= 100
        expect(choice_idents).to eq(choice_idents.sort)
      end
    end

    context 'with non-duplicate choices' do
      before do
        instance.data = [
          { 'answer' => 'Match 1', 'correct' => ['A', 'B'] },
          { 'answer' => 'Match 2', 'correct' => ['C', 'D'] }
        ]
      end

      it 'still generates sequential identifiers' do
        instance.send(:build_qti_data)
        conditions = instance.qti_response_conditions

        choice_idents = conditions.flat_map { |c| c.choices.map(&:ident) }.map(&:to_i)
        expect(choice_idents.each_cons(2).all? { |a, b| b == a + 1 }).to be_truthy
      end
    end
  end
end
