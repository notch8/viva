# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SettingsController do
  describe '#index', inertia: true do
    it "returns a 'Settings' component with a property for the current user" do
      user = FactoryBot.create(:user)
      sign_in user
      get :index

      expect_inertia.to render_component 'Settings'
      expect(inertia.props[:currentUser]).to be_a(Object)
    end
  end

  describe '#update', inertia: true do
    it 'updates user attributes and returns a success message' do
      user = FactoryBot.create(:user)
      sign_in user

      updated_attributes = {
        first_name: 'UpdatedFirstName',
        last_name: 'UpdatedLastName',
        title: 'UpdatedTitle',
        email: 'updated@example.com'
      }

      patch :update, params: updated_attributes

      user.reload
      expect(user.first_name).to eq('UpdatedFirstName')
      expect(user.last_name).to eq('UpdatedLastName')
      expect(user.title).to eq('UpdatedTitle')
      expect(user.email).to eq('updated@example.com')

      expect(response).to redirect_to(settings_path)
    end

    it 'renders the Settings component with errors if the update fails' do
      user = FactoryBot.create(:user)
      sign_in user

      invalid_attributes = {
        first_name: '',
        last_name: 'UpdatedLastName',
        title: 'UpdatedTitle',
        email: 'invalid-email'
      }

      patch :update, params: invalid_attributes

      user.reload
      expect(user.last_name).not_to eq('UpdatedLastName')
      expect(user.title).not_to eq('UpdatedTitle')

      expect_inertia.to render_component 'Settings'
      expect(inertia.props[:errors]).not_to be_empty
    end
  end

  describe '#update_password', inertia: true do
    it 'allows a user to update their password' do
      user = FactoryBot.create(:user)
      sign_in user

      password_attributes = {
        current_password: 'password',
        password: 'NewPassword123',
        password_confirmation: 'NewPassword123'
      }

      patch :update_password, params: password_attributes

      user.reload

      expect(user.valid_password?('NewPassword123')).to be true
    end

    it 'renders the Settings component with errors if the password update fails' do
      user = FactoryBot.create(:user)
      sign_in user

      invalid_password_attributes = {
        current_password: 'incorrect_password',
        password: 'NewPassword123',
        password_confirmation: 'NewPassword123'
      }

      patch :update_password, params: invalid_password_attributes

      user.reload

      expect(user.valid_password?('NewPassword123')).to be false

      expect_inertia.to render_component 'Settings'
      expect(inertia.props[:errors]).not_to be_empty
    end
  end
end
