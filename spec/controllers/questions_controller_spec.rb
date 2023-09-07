# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  # routes { Rails.application.class.routes }

  describe 'GET /questions' do
    let(:questions) { (1..2).map { FactoryBot.build(:question) } }
    let(:keywords) { ['hello'] }
    let(:categories) { ['world'] }

    before { allow(Question).to receive(:filter).with(keywords:, categories:).and_return(questions) }

    context 'as HTML' do
      it 'filters the given keywords and categories params' do
        get :index, params: { keywords:, categories: }
        expect(response).to have_http_status(:ok)
        expect(assigns(:questions)).to eq(questions)
      end
    end

    context 'as JSON' do
      it 'filters the given keywords and categories params' do
        get :index, params: { keywords:, categories: }, format: :json
        expect(response).to have_http_status(:ok)
        expect(assigns(:questions)).to eq(questions)
      end
    end
  end
end
