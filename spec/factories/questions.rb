# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    text { Faker::Lorem.unique.sentence }
    child_of_aggregation { false }

    ##
    # See https://thoughtbot.github.io/factory_bot/cookbook/has_and_belongs_to_many-associations.html
    trait :with_keywords do
      transient do
        keyword_count { 1 + rand(3) }
      end

      keywords do
        Array.new(keyword_count) { association(:keyword, questions: [instance]) }
      end
    end

    ##
    # See https://thoughtbot.github.io/factory_bot/cookbook/has_and_belongs_to_many-associations.html
    trait :with_categories do
      transient do
        category_count { 1 + rand(2) }
      end

      categories do
        Array.new(category_count) { association(:category, questions: [instance]) }
      end
    end

    # NOTE: These factory names are based on the class's model_name's param_key which helps with
    # the ./spec/shared_examples.rb
    factory :question_drag_and_drop, class: Question::DragAndDrop, parent: :question do
      data { (1..6).map { |i| { answer: "Left #{i} #{Faker::Lorem.word}", correct: i.even? } } }
    end

    factory :question_traditional, class: Question::Traditional, parent: :question do
      # In this case there are 4 candidate answers and the 3rd one is always correct (always C)
      data { (1..4).map { |i| { answer: "Answer #{i} #{Faker::Lorem.word}", correct: i == 3 } } }
    end

    factory :question_matching, class: Question::Matching, parent: :question do
      data do
        (1..4).map do |i|
          {
            answer: "Left #{i} #{Faker::Lorem.word}",
            correct: (0..rand(4)).map { |j| "Right #{i}-#{j} #{Faker::Lorem.word}" }
          }
        end
      end
    end

    factory :question_scenario, class: Question::Scenario, parent: :question do
      parent_question factory: :question_stimulus_case_study_without_children
    end

    factory :question_stimulus_case_study_without_children, class: Question::StimulusCaseStudy, parent: :question

    factory :question_stimulus_case_study, class: Question::StimulusCaseStudy, parent: :question_stimulus_case_study_without_children do
      after(:build) do |question, _context|
        child_question_classes = Question.descendants.select(&:include_in_filterable_type?) - [question.class]

        (0..5).map do |i|
          # Injecting some scenarios into the questions.
          child = if i == 0 || i == 3
                    # If we don't specify the scenario's parent, we'll build an all new one.
                    FactoryBot.build(:question_scenario, parent_question: question)
                  else
                    FactoryBot.build(child_question_classes.sample.model_name.param_key, child_of_aggregation: true)
                  end
          question.as_parent_question_aggregations.build(presentation_order: i, child_question: child)
        end
      end
    end

    factory :question_select_all_that_apply, class: Question::SelectAllThatApply, parent: :question do
      data { [{ answer: "A", correct: true }, { answer: "B", correct: true }, { answer: "C", correct: false }] }
    end

    factory :question_bow_tie, class: Question::BowTie, parent: :question do
      data do
        {
          center: {
            label: "Center Label",
            answers: [
              {
                answer: "Center correct answer",
                correct: true },
              {
                answer: "Center incorrect answer 1",
                correct: false
              },
              {
                answer: "Center incorrect answer 2",
                correct: false
              },
              {
                answer: "Center incorrect answer 3",
                correct: false
              }
            ]
          },
          left: {
            label: "Left Label",
            answers:[
              {
                answer: "Left Correct Answer 1",
                correct: true
              },
              {
                answer: "Left Correct Answer 2 with longer text to test for responsiveness",
                correct: true
              },
              {
                answer: "Left Incorrect Answer 1",
                correct: false
              },
              {
                answer: "Left Incorrect Answer 2 with longer text to test for responsiveness",
                correct: false
              },
              {
                answer: "Left Incorrect Answer 3",
                correct: false
              }
            ]
          },
          right: {
            label: "Right Label",
            answers:[
              {
                answer: "Right Correct Answer 1",
                correct: true
              },
              {
                answer: "Right Correct Answer 2",
                correct: true
              },
              {
                answer: "Right Incorrect Answer 1 with longer text to test for responsiveness",
                correct: false
              },
              {
                answer: "Right Incorrect Answer 2",
                correct: false
              },
              {
                answer: "Right Incorrect Answer 3",
                correct: false
              }
            ]
          }
        }
      end
    end
  end
end
