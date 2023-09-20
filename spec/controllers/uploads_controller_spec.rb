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
end
