# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchController do
  describe '#index', inertia: true do
    before do
      user = FactoryBot.create(:user)
      sign_in user
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
                 "images" => [],
                 "user_id" => question.user_id,
                 "hashid" => question.hashid
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
                 "images" => [],
                 "user_id" => question1.user_id,
                 "hashid" => question1.hashid
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
                 "images" => [],
                 "user_id" => question2.user_id,
                 "hashid" => question2.hashid
               }
             ])
        )

        # set the selected keywords, subjects, and types to the keywords, subjects, and types of question 1
        selected_keywords = question1.keywords.names
        selected_subjects = question1.subjects.names

        given_params = { selected_keywords:, selected_subjects: }
        get :index, params: given_params

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
                 "images" => [],
                 "user_id" => question1.user_id,
                 "hashid" => question1.hashid
               }
             ])
        )
      end

      context 'when user is an admin' do
        let(:admin_user) { FactoryBot.create(:user, admin: true) }
        let(:user1) { FactoryBot.create(:user, email: 'user1@example.com') }
        let(:user2) { FactoryBot.create(:user, email: 'user2@example.com') }

        before do
          sign_in admin_user
        end

        it 'includes users list and selectedUsers in props' do
          FactoryBot.create(:question_matching, user: user1)
          FactoryBot.create(:question_matching, user: user2)

          get :index

          expect(inertia.props[:users]).to be_a(Array)
          expect(inertia.props[:users].length).to be >= 2
          expect(inertia.props[:users].pluck(:id)).to include(admin_user.id, user1.id, user2.id)
          expect(inertia.props[:selectedUsers]).to be_nil
        end

        it 'filters questions by selected_users' do
          question1 = FactoryBot.create(:question_matching, user: user1)
          question2 = FactoryBot.create(:question_matching, user: user2)
          question3 = FactoryBot.create(:question_matching, user: admin_user)

          get :index, params: { selected_users: [user1.id] }

          expect(inertia.props[:selectedUsers]).to eq([user1.id.to_s])
          filtered_ids = inertia.props[:filteredQuestions].as_json.pluck('id')
          expect(filtered_ids).to include(question1.id)
          expect(filtered_ids).not_to include(question2.id)
          expect(filtered_ids).not_to include(question3.id)
        end

        it 'filters questions by multiple selected_users' do
          question1 = FactoryBot.create(:question_matching, user: user1)
          question2 = FactoryBot.create(:question_matching, user: user2)
          question3 = FactoryBot.create(:question_matching, user: admin_user)

          get :index, params: { selected_users: [user1.id, user2.id] }

          expect(inertia.props[:selectedUsers]).to eq([user1.id.to_s, user2.id.to_s])
          filtered_ids = inertia.props[:filteredQuestions].as_json.pluck('id')
          expect(filtered_ids).to include(question1.id, question2.id)
          expect(filtered_ids).not_to include(question3.id)
        end

        it 'ignores filter_my_questions parameter when admin uses user dropdown' do
          question1 = FactoryBot.create(:question_matching, user: user1)
          question2 = FactoryBot.create(:question_matching, user: admin_user)

          # Admin selects user1, but also has filter_my_questions=true
          # Should only filter by selected_users, ignoring filter_my_questions
          get :index, params: { selected_users: [user1.id], filter_my_questions: true }

          filtered_ids = inertia.props[:filteredQuestions].as_json.pluck('id')
          expect(filtered_ids).to include(question1.id)
          expect(filtered_ids).not_to include(question2.id)
        end

        it 'allows admin to select themselves from user dropdown' do
          question1 = FactoryBot.create(:question_matching, user: admin_user)
          question2 = FactoryBot.create(:question_matching, user: user1)

          get :index, params: { selected_users: [admin_user.id] }

          expect(inertia.props[:selectedUsers]).to eq([admin_user.id.to_s])
          filtered_ids = inertia.props[:filteredQuestions].as_json.pluck('id')
          expect(filtered_ids).to include(question1.id)
          expect(filtered_ids).not_to include(question2.id)
        end
      end

      context 'when user is not an admin' do
        let(:regular_user) { FactoryBot.create(:user, admin: false) }

        before do
          sign_in regular_user
        end

        it 'does not include users list or selectedUsers in props' do
          get :index

          expect(inertia.props[:users]).to be_nil
          expect(inertia.props[:selectedUsers]).to be_nil
        end

        it 'ignores selected_users parameter' do
          user1 = FactoryBot.create(:user)
          question1 = FactoryBot.create(:question_matching, user: user1)
          question2 = FactoryBot.create(:question_matching, user: regular_user)

          get :index, params: { selected_users: [user1.id] }

          # Should return all questions, not filtered by user
          filtered_ids = inertia.props[:filteredQuestions].as_json.pluck('id')
          expect(filtered_ids).to include(question1.id, question2.id)
        end

        it 'can use filter_my_questions to see only their questions' do
          question1 = FactoryBot.create(:question_matching, user: regular_user)
          question2 = FactoryBot.create(:question_matching, user: FactoryBot.create(:user))

          get :index, params: { filter_my_questions: true }

          expect(inertia.props[:filterMyQuestions]).to be true
          filtered_ids = inertia.props[:filteredQuestions].as_json.pluck('id')
          expect(filtered_ids).to include(question1.id)
          expect(filtered_ids).not_to include(question2.id)
        end
      end
    end
  end
end
