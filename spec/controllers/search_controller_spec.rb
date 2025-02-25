# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchController do
  describe '#index', inertia: true do
    before do
      user = FactoryBot.create(:user)
      sign_in user
    end

    context 'xml format' do
      it 'uses the search parameters to build the data' do
        FactoryBot.create(:question_traditional, :with_keywords, :with_subjects)
        get :index, format: :xml

        expect(response.content_type).to eq('application/xml; charset=utf-8')
        expect(response).to be_successful
        expect(assigns(:questions).count).to eq(1)
        # Yes, you're reading this right.  The body for attachments is empty.  We need to instead
        # check the content disposition.  Unfortunately we don't have access to the contents of that
        # file.
        expect(response.body).to be_empty
        expect(response.headers['Content-Disposition']).to match(%r{^attachment; filename="questions-\d{4}-\d{2}})
        expect(response.headers['Content-Disposition']).to end_with(%(classic-question-canvas.qti.xml"))
      end
    end

    context 'inertia format', inertia: true do
      it "returns a 'Search' component with properties of :keywords, :types, :subjects, and :filteredQuestions" do
        question = FactoryBot.create(:question_matching, :with_keywords, :with_subjects)
        get :index
        expect_inertia.to render_component 'Search'
        expect(inertia.props[:keywords]).to be_a(Array)
        expect(inertia.props[:subjects]).to be_a(Array)
        expect(inertia.props[:types]).to be_a(Array)
        expect(inertia.props[:type_names]).to be_a(Array)
        expect(inertia.props[:levels]).to be_a(Array)
        expect(inertia.props[:type_names]).to be_a(Array)
        expect(inertia.props[:exportHrefs]).to match_array([{ href: ".xml", type: "xml" }])
        expect(inertia.props[:filteredQuestions].as_json).to(
          eq([
               {
                 "id" => question.id,
                 "text" => question.text,
                 "type_name" => question.type_name,
                 "data" => question.data,
                 "type" => question.model_name.name, # Deprecated
                 "type_label" => question.type_label,
                 "level" => question.level,
                 "keyword_names" => question.keywords.names,
                 "subject_names" => question.subjects.names,
                 "alt_texts" => [],
                 "images" => []
               }
             ])
        )
      end

      # TODO: account for types and levels
      it 'makes a request using selected_keywords, selected_subjects, and selected_types, and filters the questions based on these selected values.' do
        question1 = FactoryBot.create(:question_matching, :with_keywords, :with_subjects)
        question2 = FactoryBot.create(:question_matching, :with_keywords, :with_subjects)

        get :index
        # test that we have both question 1 and 2 to start with
        expect(inertia.props[:filteredQuestions].as_json).to(
          eq([
               {
                 "id" => question1.id,
                 "text" => question1.text,
                 "type_name" => question1.type_name,
                 "data" => question1.data,
                 "type" => question1.model_name.name, # Deprecated
                 "type_label" => question1.type_label,
                 "level" => question1.level,
                 "keyword_names" => question1.keywords.names,
                 "subject_names" => question1.subjects.names,
                 "alt_texts" => [],
                 "images" => []
               },
               {
                 "id" => question2.id,
                 "text" => question2.text,
                 "type_name" => question2.type_name,
                 "data" => question2.data,
                 "type" => question2.model_name.name, # Deprecated
                 "type_label" => question2.type_label,
                 "level" => question2.level,
                 "keyword_names" => question2.keywords.names,
                 "subject_names" => question2.subjects.names,
                 "alt_texts" => [],
                 "images" => []
               }
             ])
        )

        # set the selected keywords, subjects, and types to the keywords, subjects, and types of question 1
        selected_keywords = question1.keywords.names
        selected_subjects = question1.subjects.names

        given_params = { selected_keywords:, selected_subjects: }
        get :index, params: given_params

        expect(inertia.props[:exportHrefs]).to match_array([{ href: ".xml?#{given_params.to_query}", type: "xml" }])

        # test that the page has the correct params
        expect(inertia.props[:selectedKeywords]).to eq(selected_keywords)
        expect(inertia.props[:selectedSubjects]).to eq(selected_subjects)
        # expect(inertia.props[:selectedTypes]).to eq(selected_types)

        # test that question 2 is filtered out
        expect(inertia.props[:filteredQuestions].as_json).to(
          eq([
               {
                 "id" => question1.id,
                 "text" => question1.text,
                 "type_name" => question1.type_name,
                 "data" => question1.data,
                 "type" => question1.model_name.name, # Deprecated
                 "type_label" => question1.type_label,
                 "level" => question1.level,
                 "keyword_names" => question1.keywords.names,
                 "subject_names" => question1.subjects.names,
                 "alt_texts" => [],
                 "images" => []
               }
             ])
        )
      end
    end

    context 'when a question has images' do
      it 'send a zip file with the images' do
        FactoryBot.create(:question_traditional, :with_images)
        get :index, format: :xml

        expect(response.content_type).to eq('application/zip')
        expect(response).to be_successful
        expect(response.body).to be_present
        expect(response.headers['Content-Disposition']).to match(/.zip/)
      end
    end

    context 'plain text download' do
      let(:question) { FactoryBot.create(:question_traditional) }
      let(:user) { FactoryBot.create(:user) }

      it 'returns a text file' do
        get :text_download
        expect(response.content_type).to eq('text/plain')
        expect(response.headers['Content-Disposition']).to include('questions.txt')
      end

      it 'includes bookmarked questions in the response' do
        Bookmark.create!(user:, question:)

        get :text_download
        expect(response.body).to include(question.text)
      end
    end
  end
end
