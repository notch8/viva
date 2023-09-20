# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::ImporterCsv do
  subject(:instance) { described_class.new(text) }

  context 'with valid data' do
    let(:text) do
      "IMPORT_ID,TYPE,TEXT,ANSWERS,ANSWER_1,ANSWER_2,ANSWER_3\n" \
      "1,Traditional,Which one is true?,1,true,false,Orc\n"
    end

    it 'persists the given records' do
      expect { subject.save }.to change(Question::Traditional, :count).by(1)
      expect(subject.errors).to be_empty
    end
  end

  context 'with mixed valid data' do
    let(:text) do
      "IMPORT_ID,TYPE,,TEXT,ANSWERS,ANSWER_1,ANSWER_2,RIGHT_1,LEFT_1,ANSWER_3\n" \
      "1,Traditional,,Which one is true?,1,true,false,,,Orc\n" \
      "2,Matching,,Pair Up,,,,Animal,Cat\n" \
      "3,Select All That Apply,,Which one is affirmative?,\"1,3\",true,false,,,yes\n" \
      "4,Drag and Drop,,What are Anmials?,\"1,2\",Cat,Dog,,,Shoe\n" \
      "5,Drag and Drop,,The ___1___ chases ___2___?,\"1,2\",Cat,Mouse,,,Umbrella\n"
    end

    it 'persists the given records' do
      expect do
        expect do
          expect do
            expect do
              subject.save
            end.to change(Question::Traditional, :count).by(1)
          end.to change(Question::Matching, :count).by(1)
        end.to change(Question::DragAndDrop, :count).by(2)
      end.to change(Question::SelectAllThatApply, :count).by(1)

      expect(subject.errors).to be_empty
    end
  end

  context 'with invalid data' do
    let(:text) do
      "IMPORT_ID,TYPE,TEXT,ANSWERS,ANSWER_1,ANSWER_2,ANSWER_3\n" \
      "1,Traditional,I don't know?,4,a,b,c\n"
    end

    it 'does not persist the given records' do
      expect { subject.save }.not_to change(Question::Traditional, :count)
      expect(subject.errors).not_to be_empty

      expect(subject.errors).to be_a(Array)
      expect(subject.errors.first.keys.sort).to match_array([:errors, :row])
    end
  end

  context 'without an IMPORT_ID column' do
    let(:text) do
      "TYPE,TEXT,ANSWERS,ANSWER_1,ANSWER_2,ANSWER_3\n" \
      "Traditional,I don't know?,1,a,b,c\n"
    end

    it 'does not persist the given records' do
      expect { subject.save }.not_to change(Question::Traditional, :count)
      expect(subject.errors).not_to be_empty

      expect(subject.errors).to be_a(Array)
      expect(subject.errors.first.keys.sort).to match_array([:errors, :row])
    end
  end
end
