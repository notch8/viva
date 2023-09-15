# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchController do
  describe '#index', inertia: true do
    it "returns a 'Search' component with properties of :keywords, :types, :categories, and :filtered_questions" do
      question = FactoryBot.create(:question_matching, :with_keywords, :with_categories)

      user = FactoryBot.create(:user)
      sign_in user
      get :index

      expect_inertia.to render_component 'Search'
      expect(inertia.props[:keywords]).to be_a(Array)
      expect(inertia.props[:categories]).to be_a(Array)
      expect(inertia.props[:types]).to be_a(Array)
      expect(inertia.props[:filtered_questions].as_json).to(
        eq([{ "id" => question.id,
              "text" => question.text,
              "type" => question.type,
              "level" => question.level,
              "keyword_names" => question.keywords.map(&:name),
              "category_names" => question.categories.map(&:name) }])
      )
    end
  end
end
