# spec/models/user_spec.rb

require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Devise authentication" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it 'validates the length of :encrypted_password' do
      # Create a user with a password less than the minimum required length
      user = User.new(email: 'test@example.com', password: '12345')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")

      # Create a user with a password equal to the minimum required length
      user = User.new(email: 'test@example.com', password: '123456')
      expect(user).to be_valid

      # Create a user with a password greater than the minimum required length
      user = User.new(email: 'test@example.com', password: '1234567')
      expect(user).to be_valid
    end

    it { is_expected.to have_db_column(:email).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:encrypted_password).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:email).unique(true) }
    it { is_expected.to have_db_index(:reset_password_token).unique(true) }
  end

  describe 'FactoryBot' do
    it 'has a valid factory' do
      user = FactoryBot.build(:user)
      expect(user).to be_valid
    end
  end
end
