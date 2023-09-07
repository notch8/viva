# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:text) }
  end

  describe 'associations' do
    it { should have_and_belong_to_many(:categories) }
    it { should have_and_belong_to_many(:keywords) }
  end
end
