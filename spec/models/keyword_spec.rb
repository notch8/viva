# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Keyword, type: :model do
  describe 'validations' do
    subject { FactoryBot.build(:keyword) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_and_belong_to_many(:questions) }
  end

  describe 'factories' do
    subject { FactoryBot.build(:keyword) }
    it { should be_valid }
  end
end
