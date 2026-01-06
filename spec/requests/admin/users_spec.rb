# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Users', type: :request do
  let(:regular_user) { create(:user, admin: false) }
  let(:admin_user) { create(:user, admin: true) }

  describe 'GET /admin' do
    context 'when user is not an admin' do
      before do
        sign_in regular_user
        get admin_root_path
      end

      it 'redirects to root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'does not allow access' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is an admin' do
      before do
        sign_in admin_user
        get admin_root_path
      end

      it 'allows access' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the admin page' do
        expect(response).to be_successful
      end
    end

    context 'when user is not logged in' do
      before { get admin_root_path }

      it 'redirects to login' do
        expect(response).to redirect_to(unauthenticated_root_path)
      end
    end
  end

  describe 'POST /admin/users - creating invitations' do
    context 'when admin creates a user' do
      before do
        sign_in admin_user
      end

      it 'sends an invitation to the new user' do
        expect do
          post admin_users_path, params: { user: { email: 'newuser@example.com' } }
        end.to change { User.count }.by(1)

        new_user = User.find_by(email: 'newuser@example.com')
        expect(new_user.invitation_sent_at).to be_present
        expect(new_user.invitation_token).to be_present
      end
    end

    context 'when non-admin tries to create a user' do
      before do
        sign_in regular_user
      end

      it 'does not allow access' do
        post admin_users_path, params: { user: { email: 'newuser@example.com' } }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
