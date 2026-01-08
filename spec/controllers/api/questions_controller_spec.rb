# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::QuestionsController, type: :controller do
  before do
    user = create(:user)
    sign_in user
  end

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
          alt_text: ['A descriptive alt text for test image'],
          keywords: ['France', 'Capital Cities'],
          subjects: ['Geography', 'Invalid']
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
          alt_text: ['Drag and drop question image description'],
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
                type: 'Question::BowTie',
                text: 'bow tie sub question',
                data: {
                  center: {
                    label: "Center Label",
                    answers: [{ answer: "a", correct: true }]
                  },
                  left: {
                    label: "Left Label",
                    answers: [{ answer: "v", correct: true }]
                  },
                  right: {
                    label: "Right Label",
                    answers: [{ answer: "v", correct: true }]
                  }
                }
              },
              {
                type: 'Question::Categorization',
                text: 'Categorize climate effects.',
                data: [
                  { answer: 'Rising temperatures', correct: ['Global warming'] },
                  { answer: 'Severe weather', correct: ['Climate change'] }
                ]
              },
              {
                type: 'Question::DragAndDrop',
                text: 'Drag the effects to their causes.',
                data: [
                  { answer: 'Glacial melting', correct: true },
                  { answer: 'Wildfires', correct: true }
                ]
              },
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
              },
              {
                type: 'Question::SelectAllThatApply',
                text: 'Select all the impacts of deforestation.',
                data: [
                  { answer: 'Loss of biodiversity', correct: true },
                  { answer: 'Increased CO2 levels', correct: true },
                  { answer: 'Ozone depletion', correct: false }
                ]
              },
              {
                type: 'Question::Traditional',
                text: 'What is the most significant contributor to climate change?',
                data: [
                  { answer: 'Burning fossil fuels', correct: true },
                  { answer: 'Planting trees', correct: false },
                  { answer: 'Recycling waste', correct: false }
                ]
              },
              {
                type: 'Question::Upload',
                text: 'Upload your analysis of the data.',
                data: { html: '<p>Please upload your file with detailed analysis.</p>' }
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

    let(:upload_params) do
      {
        question: {
          type: 'Question::Upload',
          level: '2',
          text: 'Please upload your solution file.',
          data: { html: '<p>Please upload your solution file.</p>' }.to_json,
          images: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png'), 'image/png')
          ],
          keywords: ['Upload', 'Solution'],
          subjects: ['Programming']
        }
      }
    end

    let(:invalid_params) do
      { question: { text: '' } }
    end
    let(:subject) { create(:subject, name:) }
    let(:name) { subject_name }
    let(:subject_name) { 'something' }
    let(:invalid_subject_name) { 'invalid' }

    before do
      allow(Subject).to receive(:find_by).with(name:).and_return(subject)
      allow(Subject).to receive(:find_by).with(name: invalid_subject_name).and_return(nil)
      allow(Subject).to receive(:find_by).and_call_original
    end

    context 'when creating an Essay question' do
      let(:subject_name) { 'Geography' }

      it 'creates an essay question with all parameters' do
        expect { post :create, params: essay_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('What is the capital of France?')
        expect(question.level).to eq('2')
        expect(question.data).to eq({ 'html' => '<p>What is the capital of France?</p>' })
        expect(question.images.count).to eq(1)
        expect(question.images.first.alt_text).to eq('A descriptive alt text for test image')
        expect(question.keywords.map(&:name)).to contain_exactly('france', 'capital cities')
        expect(question.subjects.map(&:name)).to contain_exactly('Geography')
        expect(question.subjects.map(&:name)).to_not include('Invalid')
      end
    end

    context 'when creating a Drag and Drop question' do
      let(:subject_name) { 'Logic' }

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
        expect(question.subjects.map(&:name)).to contain_exactly('Logic')
      end
    end

    context 'when creating a Matching question' do
      let(:subject_name) { 'Pharmacology' }

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
        expect(question.subjects.map(&:name)).to contain_exactly('Pharmacology')
      end
    end

    context 'when creating a Categorization question' do
      let(:subject_name) { 'Nutrition' }

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
        expect(question.subjects.map(&:name)).to contain_exactly('Nutrition')
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
      context 'with valid parameters' do
        let(:subject_name) { 'Biology' }

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
          expect(question.subjects.map(&:name)).to contain_exactly('Biology')
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

      context 'with invalid parameters' do
        it 'does not create a Multiple Choice question with invalid data' do
          invalid_data_params = multiple_choice_params.deep_merge(question: { data: 'foo' })

          expect { post :create, params: invalid_data_params }.not_to change(Question, :count)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to include('Multiple Choice questions require at least one answer.')
        end
      end
    end

    context 'when creating a Select All That Apply question' do
      let(:subject_name) { 'Biology' }

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
        expect(question.subjects.map(&:name)).to contain_exactly('Biology')
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
          .to change(Question, :count).by(9) # 1 parent + 8 subquestions
      end

      context 'with valid parameters' do
        it 'creates a Stimulus Case Study parent question' do
          post :create, params: stimulus_case_study_params
          question = Question.find_by(type: 'Question::StimulusCaseStudy')

          # Ensure the parent question is created with correct attributes
          expect(question).not_to be_nil
          expect(question.text).to eq('Analyze the impact of climate change on polar regions.')
          expect(question.level).to eq('4')
        end
      end

      context 'with invalid parameters' do
        it 'does not create a Stimulus Case Study question with invalid data' do
          invalid_data_params = stimulus_case_study_params.deep_merge(question: { data: {}.to_json })

          expect { post :create, params: invalid_data_params }.not_to change(Question, :count)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to include('Stimulus Case Study data is required.')
        end
      end

      context 'creates subquestions for the Stimulus Case Study' do
        let(:question) { Question.find_by(type: 'Question::StimulusCaseStudy') }
        let(:sub_questions) { question.child_questions }

        before do
          post :create, params: stimulus_case_study_params
        end

        it 'creates subquestions' do
          expect(sub_questions.count).to eq(8)
        end

        context 'when subquestion type is BowTie' do
          it 'creates a BowTie subquestion for the Stimulus Case Study' do
            bow_tie_sub_question = sub_questions.find_by(type: 'Question::BowTie')
            expect(bow_tie_sub_question.text).to eq('bow tie sub question')
            expect(bow_tie_sub_question.data).to eq({
                                                      "center" => { "answers" => [{ "answer" => "a", "correct" => true }], "label" => "Center Label" },
                                                      "left" => { "answers" => [{ "answer" => "v", "correct" => true }], "label" => "Left Label" },
                                                      "right" => { "answers" => [{ "answer" => "v", "correct" => true }], "label" => "Right Label" }
                                                    })
          end
        end

        context 'when subquestion type is Categorization' do
          it 'creates a Categorization subquestion for the Stimulus Case Study' do
            categorization_sub_question = sub_questions.find_by(type: 'Question::Categorization')
            expect(categorization_sub_question.text).to eq('Categorize climate effects.')
            expect(categorization_sub_question.data).to eq([
                                                             { 'answer' => 'Rising temperatures', 'correct' => ['Global warming'] },
                                                             { 'answer' => 'Severe weather', 'correct' => ['Climate change'] }
                                                           ])
          end
        end

        context 'when subquestion type is DragAndDrop' do
          it 'creates a Drag and Drop subquestion for the Stimulus Case Study' do
            drag_and_drop_sub_question = sub_questions.find_by(type: 'Question::DragAndDrop')
            expect(drag_and_drop_sub_question.text).to eq('Drag the effects to their causes.')
            expect(drag_and_drop_sub_question.data).to eq([
                                                            { 'answer' => 'Glacial melting', 'correct' => true },
                                                            { 'answer' => 'Wildfires', 'correct' => true }
                                                          ])
          end
        end

        context 'when subquestion type is Essay' do
          it 'creates an Essay subquestion for the Stimulus Case Study' do
            essay_sub_question = sub_questions.find_by(type: 'Question::Essay')
            expect(essay_sub_question.text).to eq('What are the primary causes of climate change?')
            expect(essay_sub_question.data).to eq({ 'html' => '<p>Discuss the primary causes of climate change.</p>' })
          end
        end

        context 'when subquestion type is Matching' do
          it 'creates a Matching subquestion for the Stimulus Case Study' do
            matching_sub_question = sub_questions.find_by(type: 'Question::Matching')
            expect(matching_sub_question.text).to eq('Match the effects with their corresponding causes.')
            expect(matching_sub_question.data).to eq([
                                                       { 'answer' => 'Melting glaciers', 'correct' => ['Rising temperatures'] },
                                                       { 'answer' => 'Droughts', 'correct' => ['Deforestation'] }
                                                     ])
          end
        end

        context 'when subquestion type is SelectAllThatApply' do
          it 'creates a Select All That Apply subquestion for the Stimulus Case Study' do
            select_all_sub_question = sub_questions.find_by(type: 'Question::SelectAllThatApply')
            expect(select_all_sub_question.text).to eq('Select all the impacts of deforestation.')
            expect(select_all_sub_question.data).to eq([
                                                         { 'answer' => 'Loss of biodiversity', 'correct' => true },
                                                         { 'answer' => 'Increased CO2 levels', 'correct' => true },
                                                         { 'answer' => 'Ozone depletion', 'correct' => false }
                                                       ])
          end
        end

        context 'when subquestion type is Upload' do
          it 'creates an Upload subquestion for the Stimulus Case Study' do
            upload_sub_question = sub_questions.find_by(type: 'Question::Upload')
            expect(upload_sub_question.text).to eq('Upload your analysis of the data.')
            expect(upload_sub_question.data).to eq({ 'html' => '<p>Please upload your file with detailed analysis.</p>' })
          end
        end

        context 'when subquestion type is Traditional' do
          it 'creates a Traditional subquestion for the Stimulus Case Study' do
            traditional_sub_question = sub_questions.find_by(type: 'Question::Traditional')
            expect(traditional_sub_question.text).to eq('What is the most significant contributor to climate change?')
            expect(traditional_sub_question.data).to eq([
                                                          { 'answer' => 'Burning fossil fuels', 'correct' => true },
                                                          { 'answer' => 'Planting trees', 'correct' => false },
                                                          { 'answer' => 'Recycling waste', 'correct' => false }
                                                        ])
          end
        end
      end
    end

    context 'when creating an Upload question' do
      let(:subject_name) { 'Programming' }

      it 'creates an upload question with all parameters' do
        expect { post :create, params: upload_params }.to change(Question, :count).by(1)
        question = Question.last

        expect(question.text).to eq('Please upload your solution file.')
        expect(question.level).to eq('2')
        expect(question.data).to eq({ 'html' => '<p>Please upload your solution file.</p>' })
        expect(question.images.count).to eq(1)
        expect(question.keywords.map(&:name)).to contain_exactly('upload', 'solution')
        expect(question.subjects.map(&:name)).to contain_exactly('Programming')
        expect(question.subjects.map(&:name)).to_not include('Invalid')
      end
    end

    context 'with invalid parameters' do
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

  describe 'DELETE #destroy' do
    let(:new_question) { FactoryBot.create(:question_traditional, user: test_user) }
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context 'when the question belongs to current_user' do
      let(:test_user) { user }

      it 'deletes the question' do
        sign_in user
        question = new_question

        expect do
          delete :destroy, params: { id: question.id }
        end.to change(Question, :count).by(-1)

        expect(response).to have_http_status(302)
      end
    end

    context 'when the question does not belong to current_user' do
      let(:test_user) { other_user }

      it 'does not delete the question' do
        question = new_question
        sign_in user

        expect do
          delete :destroy, params: { id: question.id }
        end.not_to change(Question, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the user is an admin' do
      let(:test_user) { other_user }

      it 'deletes the question' do
        admin = create(:user, :admin)
        sign_in admin
        question = new_question

        expect do
          delete :destroy, params: { id: question.id }
        end.to change(Question, :count).by(-1)

        expect(response).to have_http_status(302)
      end
    end
  end
end
