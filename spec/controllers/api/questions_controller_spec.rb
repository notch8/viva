# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::QuestionsController, type: :controller do
  describe 'POST #create' do
    let(:essay_params) do
      {
        question: {
          type: 'Question::Essay',
          level: '2',
          text: 'What is the capital of France?',
          data: { html: '<p>What is the capital of France?</p>' }.to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['France', 'Capital Cities'],
          subjects: ['Geography']
        }
      }
    end

    let(:drag_and_drop_params) do
      {
        question: {
          type: 'Question::DragAndDrop',
          level: '3',
          text: 'Arrange the items in the correct order.',
          data: [
            { "answer" => "Option A", "correct" => true },
            { "answer" => "Option B", "correct" => false }
          ].to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['Ordering', 'DragDrop'],
          subjects: ['Logic']
        }
      }
    end

    let(:bow_tie_params) do
      {
        question: {
          type: 'Question::BowTie',
          level: '5',
          text: 'Lifecycle of chemicals',
          data: {
            "center" => {
              "label" => "Center Label",
              "answers" => [
                { "answer" => "Center correct answer", "correct" => true },
                { "answer" => "Center incorrect answer 1", "correct" => false },
                { "answer" => "Center incorrect answer 2", "correct" => false },
                { "answer" => "Center incorrect answer 3", "correct" => false }
              ]
            },
            "left" => {
              "label" => "Left Label",
              "answers" => [
                { "answer" => "Left Correct Answer 1", "correct" => true },
                { "answer" => "Left Correct Answer 2 with longer text to test for responsiveness", "correct" => true },
                { "answer" => "Left Incorrect Answer 1", "correct" => false },
                { "answer" => "Left Incorrect Answer 2 with longer text to test for responsiveness", "correct" => false },
                { "answer" => "Left Incorrect Answer 3", "correct" => false }
              ]
            },
            "right" => {
              "label" => "Right Label",
              "answers" => [
                { "answer" => "Right Correct Answer 1", "correct" => true },
                { "answer" => "Right Correct Answer 2", "correct" => true },
                { "answer" => "Right Incorrect Answer 1 with longer text to test for responsiveness", "correct" => false },
                { "answer" => "Right Incorrect Answer 2", "correct" => false },
                { "answer" => "Right Incorrect Answer 3", "correct" => false }
              ]
            }
          }.to_json
        }
      }
    end

    let(:matching_params) do
      {
        question: {
          type: 'Question::Matching',
          level: '1',
          text: 'Match the inhibitors with their respective drug names.',
          data: [
            { "answer" => "Selective Serotonin Reuptake Inhibitors", "correct" => ["Citalopram"] },
            { "answer" => "Serotonin-norepinephrine Reuptake Inhibitors", "correct" => ["Desvenlafaxine"] }
          ].to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['SSRIs', 'SNRIs'],
          subjects: ['Pharmacology']
        }
      }
    end

    let(:categorization_params) do
      {
        question: {
          type: 'Question::Categorization',
          level: '4',
          text: 'Categorize the following items.',
          data: [
            { "answer" => "Fruits", "correct" => ["Apple", "Banana", "Cherry"] },
            { "answer" => "Vegetables", "correct" => ["Carrot", "Broccoli", "Spinach"] }
          ].to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['Food Groups', 'Categorization'],
          subjects: ['Nutrition']
        }
      }
    end

    let(:multiple_choice_params) do
      {
        question: {
          type: 'Question::Traditional',
          level: '2',
          text: 'Which of the following is a fruit?',
          data: [
            { "answer" => "Apple", "correct" => true },
            { "answer" => "Carrot", "correct" => false },
            { "answer" => "Broccoli", "correct" => false },
            { "answer" => "Celery", "correct" => false }
          ].to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['Fruits', 'Food Groups'],
          subjects: ['Biology']
        }
      }
    end

    let(:select_all_params) do
      {
        question: {
          type: 'Question::SelectAllThatApply',
          level: '3',
          text: 'Select all the fruits from the following options:',
          data: [
            { "answer" => "Apple", "correct" => true },
            { "answer" => "Banana", "correct" => true },
            { "answer" => "Carrot", "correct" => false },
            { "answer" => "Orange", "correct" => true }
          ].to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['Fruits', 'Food Groups'],
          subjects: ['Biology']
        }
      }
    end

    let(:stimulus_case_study_params) do
      {
        question: {
          type: 'Question::StimulusCaseStudy',
          level: '4',
          text: 'Analyze the impact of climate change on polar regions.',
          data: {
            text: 'Analyze the impact of climate change on polar regions.',
            subQuestions: [
              {
                type: 'Question::Essay',
                text: 'What are the primary causes of climate change?',
                data: { html: '<p>Discuss the primary causes of climate change.</p>' }
              },
              {
                type: 'Question::Matching',
                text: 'Match the effects with their corresponding causes.',
                data: [
                  { answer: 'Melting glaciers', correct: ['Rising temperatures'] },
                  { answer: 'Droughts', correct: ['Deforestation'] }
                ]
              }
            ]
          }.to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['Climate Change', 'Polar Regions'],
          subjects: ['Environment']
        }
      }
    end

    let(:invalid_params) do
      { question: { text: '' } }
    end

    context 'when creating an essay question' do
      it 'creates an essay question with all parameters' do
        expect { post :create, params: essay_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('What is the capital of France?')
        expect(question.level).to eq('2')
        expect(question.data).to eq({ 'html' => '<p>What is the capital of France?</p>' })
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('france', 'capital cities')
        expect(question.subjects.map(&:name)).to contain_exactly('geography')
      end
    end

    context 'when creating a Drag and Drop question' do
      it 'creates a Drag and Drop question with all parameters' do
        expect { post :create, params: drag_and_drop_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('Arrange the items in the correct order.')
        expect(question.level).to eq('3')
        expect(question.data).to eq(
          [
            { "answer" => "Option A", "correct" => true },
            { "answer" => "Option B", "correct" => false }
          ]
        )
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('ordering', 'dragdrop')
        expect(question.subjects.map(&:name)).to contain_exactly('logic')
      end
    end

    context 'when creating a Matching question' do
      it 'creates a Matching question with all parameters' do
        expect { post :create, params: matching_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('Match the inhibitors with their respective drug names.')
        expect(question.level).to eq('1')
        expect(question.data).to eq(
          [
            { "answer" => "Selective Serotonin Reuptake Inhibitors", "correct" => ["Citalopram"] },
            { "answer" => "Serotonin-norepinephrine Reuptake Inhibitors", "correct" => ["Desvenlafaxine"] }
          ]
        )
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('ssris', 'snris')
        expect(question.subjects.map(&:name)).to contain_exactly('pharmacology')
      end
    end

    context 'when creating a Categorization question' do
      it 'creates a Categorization question with all parameters' do
        expect { post :create, params: categorization_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('Categorize the following items.')
        expect(question.level).to eq('4')
        expect(question.data).to eq(
          [
            { "answer" => "Fruits", "correct" => ["Apple", "Banana", "Cherry"] },
            { "answer" => "Vegetables", "correct" => ["Carrot", "Broccoli", "Spinach"] }
          ]
        )
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('food groups', 'categorization')
        expect(question.subjects.map(&:name)).to contain_exactly('nutrition')
      end

      it 'does not create a Categorization question with invalid data' do
        invalid_data_params = categorization_params.deep_merge(question: { data: [].to_json })

        expect { post :create, params: invalid_data_params }.not_to change(Question, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include('expected to be a non-empty array.')
      end
    end

    context 'when creating a Bow Tie question' do
      context 'with valid parameters' do
        it 'creates a new Bow Tie question' do
          post :create, params: bow_tie_params
          expect { post :create, params: bow_tie_params }.to change(Question, :count).by(1)
          question = Question.last

          expect(question).not_to be_nil
          expect(question.text).to eq('Lifecycle of chemicals')
          expect(question.level).to eq('5')
          expect(question.data).to eq(
            {
              "center" => {
                "label" => "Center Label",
                "answers" => [
                  { "answer" => "Center correct answer", "correct" => true },
                  { "answer" => "Center incorrect answer 1", "correct" => false },
                  { "answer" => "Center incorrect answer 2", "correct" => false },
                  { "answer" => "Center incorrect answer 3", "correct" => false }
                ]
              },
              "left" => {
                "label" => "Left Label",
                "answers" => [
                  { "answer" => "Left Correct Answer 1", "correct" => true },
                  { "answer" => "Left Correct Answer 2 with longer text to test for responsiveness", "correct" => true },
                  { "answer" => "Left Incorrect Answer 1", "correct" => false },
                  { "answer" => "Left Incorrect Answer 2 with longer text to test for responsiveness", "correct" => false },
                  { "answer" => "Left Incorrect Answer 3", "correct" => false }
                ]
              },
              "right" => {
                "label" => "Right Label",
                "answers" => [
                  { "answer" => "Right Correct Answer 1", "correct" => true },
                  { "answer" => "Right Correct Answer 2", "correct" => true },
                  { "answer" => "Right Incorrect Answer 1 with longer text to test for responsiveness", "correct" => false },
                  { "answer" => "Right Incorrect Answer 2", "correct" => false },
                  { "answer" => "Right Incorrect Answer 3", "correct" => false }
                ]
              }
            }
          )
        end
      end
    end

    context 'when creating a Multiple Choice question' do
      it 'creates a Multiple Choice question with all parameters' do
        expect { post :create, params: multiple_choice_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('Which of the following is a fruit?')
        expect(question.level).to eq('2')
        expect(question.data).to eq([
                                      { "answer" => "Apple", "correct" => true },
                                      { "answer" => "Carrot", "correct" => false },
                                      { "answer" => "Broccoli", "correct" => false },
                                      { "answer" => "Celery", "correct" => false }
                                    ])
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('fruits', 'food groups')
        expect(question.subjects.map(&:name)).to contain_exactly('biology')
      end

      it 'does not create a Multiple Choice question with multiple correct answers' do
        invalid_data_params = multiple_choice_params.deep_merge(
          question: {
            data: [
              { "answer" => "Apple", "correct" => true },
              { "answer" => "Banana", "correct" => true }
            ].to_json
          }
        )

        expect { post :create, params: invalid_data_params }.not_to change(Question, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include('Multiple Choice questions must have exactly one correct answer.')
      end

      it 'does not create a Multiple Choice question with no correct answers' do
        invalid_data_params = multiple_choice_params.deep_merge(
          question: {
            data: [
              { "answer" => "Apple", "correct" => false },
              { "answer" => "Banana", "correct" => false }
            ].to_json
          }
        )

        expect { post :create, params: invalid_data_params }.not_to change(Question, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include('Multiple Choice questions must have exactly one correct answer.')
      end
    end

    context 'when creating a Select All That Apply question' do
      it 'creates a Select All That Apply question with all parameters' do
        expect { post :create, params: select_all_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('Select all the fruits from the following options:')
        expect(question.level).to eq('3')
        expect(question.data).to eq([
                                      { "answer" => "Apple", "correct" => true },
                                      { "answer" => "Banana", "correct" => true },
                                      { "answer" => "Carrot", "correct" => false },
                                      { "answer" => "Orange", "correct" => true }
                                    ])
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('fruits', 'food groups')
        expect(question.subjects.map(&:name)).to contain_exactly('biology')
      end

      it 'does not create a Select All That Apply question with no correct answers' do
        invalid_data_params = select_all_params.deep_merge(
          question: {
            data: [
              { "answer" => "Apple", "correct" => false },
              { "answer" => "Banana", "correct" => false }
            ].to_json
          }
        )

        expect { post :create, params: invalid_data_params }.not_to change(Question, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include('Select All That Apply questions must have at least one correct answer.')
      end

      it 'validates that answers are not blank' do
        invalid_data_params = select_all_params.deep_merge(
          question: {
            data: [
              { "answer" => "", "correct" => true },
              { "answer" => "  ", "correct" => true }
            ].to_json
          }
        )

        expect { post :create, params: invalid_data_params }.not_to change(Question, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when creating a Stimulus Case Study question' do
      it 'increases the Question count for parent and subquestions' do
        expect { post :create, params: stimulus_case_study_params }
          .to change(Question, :count).by(3) # 1 parent + 2 subquestions
      end

      it 'creates a Stimulus Case Study parent question' do
        post :create, params: stimulus_case_study_params
        question = Question.find_by(type: 'Question::StimulusCaseStudy')

        # Ensure the parent question is created with correct attributes
        expect(question).not_to be_nil
        expect(question.text).to eq('Analyze the impact of climate change on polar regions.')
        expect(question.level).to eq('4')
      end

      it 'creates subquestions for the Stimulus Case Study' do
        post :create, params: stimulus_case_study_params
        question = Question.find_by(type: 'Question::StimulusCaseStudy')
        sub_questions = question.child_questions

        # Ensure subquestions are created
        expect(sub_questions.count).to eq(2)

        # Validate attributes of the first subquestion
        first_sub_question = sub_questions.find_by(type: 'Question::Essay')
        expect(first_sub_question.text).to eq('What are the primary causes of climate change?')
        expect(first_sub_question.data).to eq({ 'html' => '<p>Discuss the primary causes of climate change.</p>' })

        # Validate attributes of the second subquestion
        second_sub_question = sub_questions.find_by(type: 'Question::Matching')
        expect(second_sub_question.text).to eq('Match the effects with their corresponding causes.')
        expect(second_sub_question.data).to eq(
          [
            { 'answer' => 'Melting glaciers', 'correct' => ['Rising temperatures'] },
            { 'answer' => 'Droughts', 'correct' => ['Deforestation'] }
          ]
        )
      end
    end

    context 'when the request is invalid' do
      it 'does not create a new question' do
        expect { post :create, params: invalid_params }.not_to change(Question, :count)
      end

      it 'returns errors for invalid request' do
        post :create, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to be_present
      end
    end
  end
end
