# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchController do
  describe '#index', inertia: true do
    it "returns a 'Search' component with properties of :keywords, :categories, and :filtered_questions" do
      question = FactoryBot.create(:question)
      user = FactoryBot.create(:user)
      sign_in user
      get :index

      expect_inertia.to render_component 'Search'
      expect(inertia.props[:keywords]).to be_a(Array)
      expect(inertia.props[:categories]).to be_a(Array)
      expect(inertia.props[:filtered_questions].as_json).to eq([{ "id" => question.id, "text" => question.text }])
    end
  end
end
