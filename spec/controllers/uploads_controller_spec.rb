# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadsController do
  describe '#index', inertia: true do
    before do
      user = FactoryBot.create(:user)
      sign_in user
    end

    it "returns an 'Uploads' component" do
      get :index
      expect_inertia.to render_component 'Uploads'
    end
  end

  describe '#create', inertia: true do
    before do
      user = FactoryBot.create(:user)
      sign_in user
    end

    context 'with valid data' do
      let(:file) { fixture_file_upload("valid_multiple_choice_question.csv", "text/csv") }

      before do
        Subject.create(name: 'Science')
        Subject.create(name: 'Metaphysics')
        Subject.create(name: 'Civics')
      end

      it "will respond with a :success code (e.g. 200), there won't be any errors, and Question records will be created." do
        expect do
          post :create, params: { csv: { "0" => file } }
        end.to change(Question, :count)

        expect_inertia.to render_component 'Uploads'
        expect(inertia.props[:errors]).to be_empty
        expect(inertia.props[:questions]).not_to be_empty
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid data' do
      let(:file) { fixture_file_upload("invalid_questions.csv", "text/csv") }

      it "will respond with an :unprocessable_entity code (e.g. 422), errors will be present, and no Question records will be created." do
        expect do
          post :create, params: { csv: { "0" => file } }
        end.not_to change(Question, :count)

        expect_inertia.to render_component 'Uploads'
        expect(inertia.props[:errors]).to be_present
        expect(inertia.props[:questions]).not_to be_empty
        expect(response).to have_http_status(422)
      end
    end

    context 'with a malformed CSV' do
      let(:file) { fixture_file_upload("malformed_sata_question.csv", "text/csv") }

      it "will respond with an :unprocessable_entity code (e.g. 422), errors will be present, and no Question records will be created." do
        expect do
          post :create, params: { csv: { "0" => file } }
        end.not_to change(Question, :count)

        expect_inertia.to render_component 'Uploads'
        expect(inertia.props[:errors]).to be_present
        expect(inertia.props[:questions]).not_to be_empty
        expect(response).to have_http_status(422)
      end
    end
  end
end
