# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:bookmarks).dependent(:destroy) }
  it { should have_many(:bookmarked_questions).through(:bookmarks).source(:question) }

  describe 'default attributes' do
    context 'when creating a new user' do
      let(:user) { create(:user) }

      it 'should be active by default' do
        expect(user.active).to be true
      end

      it 'should not be an admin by default' do
        expect(user.admin).to be false
      end
    end
  end

  describe 'active status' do
    let(:user) { create(:user) }

    it 'can be set to inactive' do
      user.update(active: false)
      expect(user.active).to be false
    end

    describe '#active_for_authentication?' do
      context 'when user is active' do
        it 'returns true' do
          expect(user.active_for_authentication?).to be true
        end
      end

      context 'when user is inactive' do
        before { user.update(active: false) }

        it 'returns false' do
          expect(user.active_for_authentication?).to be false
        end
      end
    end
  end

  describe 'admin status' do
    let(:user) { create(:user) }

    it 'can be set to admin' do
      user.update(admin: true)
      expect(user.admin).to be true
    end
  end

  describe 'invitation acceptance' do
    let(:invited_user) { User.invite!(email: 'invited@example.com') }

    it 'creates a user with invitation_sent_at timestamp' do
      expect(invited_user.invitation_sent_at).to be_present
    end

    it 'user becomes valid after accepting invitation' do
      invited_user.accept_invitation!
      invited_user.reload

      expect(invited_user.invitation_accepted_at).to be_present
      expect(invited_user.encrypted_password).to be_present
      expect(invited_user.active).to be true
    end
  end
end
