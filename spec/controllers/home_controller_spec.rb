# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  describe '#index', inertia: true do
    it 'exposes the :keywords and :categories props' do
      user = FactoryBot.create(:user)
      sign_in user
      get :index

      expect_inertia.to render_component 'App'
      expect(inertia.props[:keywords]).to be_a(Array)
      expect(inertia.props[:categories]).to be_a(Array)
    end
  end
end
