# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    text { Faker::Lorem.unique.sentence }
    child_of_aggregation { false }

    # NOTE: These factory names are based on the class's model_name's param_key which helps with
    # the ./spec/shared_examples.rb
    factory :question_drag_and_drop, class: Question::DragAndDrop, parent: :question do
      data { (1..6).map { |i| ["Left #{i} #{Faker::Lorem.unique.word}", i.even?] } }
    end

    factory :question_traditional, class: Question::Traditional, parent: :question do
      # In this case there are 4 candidate answers and the 3rd one is always correct (always C)
      data { (1..4).map { |i| ["Left #{i} #{Faker::Lorem.unique.word}", i == 3] } }
    end

    factory :question_matching, class: Question::Matching, parent: :question do
      data { (1..4).map { |i| ["Left #{i} #{Faker::Lorem.unique.word}", "Right #{i} #{Faker::Lorem.unique.word}"] } }
    end

    factory :question_stimulus_case_study, class: Question::StimulusCaseStudy, parent: :question do
      after(:build) do |question, _context|
        child_question_classes = Question.descendants - [question.class]
        (0..rand(4)).map do |i|
          child = FactoryBot.build(child_question_classes.sample.model_name.param_key, child_of_aggregation: true)
          question.as_parent_question_aggregations.build(presentation_order: i, child_question: child)
        end
      end
    end

    factory :question_select_all_that_apply, class: Question::SelectAllThatApply, parent: :question do
      data { [["A", true], ["B", true], ["C", false]] }
    end

    factory :question_bow_tie, class: Question::BowTie, parent: :question do
      data do
        { center: { label: "Center Label", answers: [["To Select", true], ["To Skip", false]] },
          left: { label: "Center Label", answers: [["LCorrect", true], ["LIncorrect", false]] },
          right: { label: "Center Label", answers: [["RCorrect", true], ["LIncorrect", false]] } }
      end
    end
  end
end
