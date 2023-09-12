# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    text { Faker::Lorem.unique.sentence }
    nested { false }

    # NOTE: These factory names are based on the class's model_name's param_key which helps with
    # the ./spec/shared_examples.rb
    factory :question_drag_and_drop, class: Question::DragAndDrop, parent: :question
    factory :question_traditional, class: Question::Traditional, parent: :question
    factory :question_matching, class: Question::Matching, parent: :question do
      data { (1..4).map { |i| ["Left #{i} #{Faker::Lorem.unique.word}", "Right #{i} #{Faker::Lorem.unique.word}"] } }
    end
    factory :question_stimulus_case_study, class: Question::StimulusCaseStudy, parent: :question
    factory :question_select_all_that_apply, class: Question::SelectAllThatApply, parent: :question do
      data { [["A", true], ["B", true], ["C", false]] }
    end
  end
end
