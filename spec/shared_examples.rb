# frozen_string_literal: true

RSpec.shared_examples 'a Question' do |valid: true|
  describe 'validations' do
    subject { described_class.new }
    it { is_expected.to validate_presence_of(:text) }
  end

  describe 'associations' do
    subject { described_class.new }
    it { is_expected.to have_and_belong_to_many(:categories) }
    it { is_expected.to have_and_belong_to_many(:keywords) }
    it { is_expected.to have_one(:as_child_question_aggregations) }
    it { is_expected.to have_one(:parent_question) }
  end

  describe 'factories' do
    subject { FactoryBot.build(described_class.model_name.param_key) }

    if valid
      it { is_expected.to be_valid }
    else
      it { is_expected.not_to be_valid }
    end
  end
end
