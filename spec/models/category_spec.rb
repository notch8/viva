# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  describe '.names' do
    subject { described_class.names }
    it { is_expected.to be_a(Array) }
  end

  describe 'validations' do
    subject { FactoryBot.build(:category) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:questions) }
  end

  describe 'factories' do
    subject { FactoryBot.build(:category) }

    it { is_expected.to be_valid }
  end

  it { is_expected.to have_implicit_order_column(:name) }
end
