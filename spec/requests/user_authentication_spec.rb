# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Authentication', type: :request do
  describe 'POST /login' do
    let(:user) { create(:user, password: 'password123') }

    context 'when user is active' do
      before do
        user.update(active: true)
      end

      it 'allows login and redirects' do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: 'password123'
          }
        }

        expect(response).to have_http_status(:redirect)
        expect(response).not_to redirect_to(new_user_session_path)
      end
    end

    context 'when user is inactive' do
      before do
        user.update(active: false)
      end

      it 'does not allow login and re-renders the login form' do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: 'password123'
          }
        }

        expect(response).to redirect_to(new_user_session_path)
        # Should not be signed in
        expect(session[:user_id]).to be_nil
      end

      it 'displays inactive account message' do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: 'password123'
          }
        }

        # Should render the login page with an error message
        expect(flash[:alert]).to include('not active')
        follow_redirect!
        expect(response.body).to include('not active')
      end
    end
  end

  describe 'GET /register' do
    it 'is not accessible (registration disabled)' do
      expect { get '/register' }.to raise_error(ActionController::RoutingError)
    end
  end

  describe 'GET /password/new' do
    it 'should be accessible (password reset enabled)' do
      get new_user_password_path
      expect(response).to have_http_status(:ok)
    end
  end
end
