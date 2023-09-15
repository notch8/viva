# frozen_string_literal: true

RSpec.shared_examples 'a Question' do |valid: true, test_type_name_to_class: true|
  it { is_expected.to respond_to(:keyword_names) }
  it { is_expected.to respond_to(:category_names) }
  its(:keyword_names) { is_expected.to be_a(Array) }
  its(:category_names) { is_expected.to be_a(Array) }
  its(:type_label) { is_expected.to be_a(String) }
  its(:type_name) { is_expected.to be_a(String) }

  if test_type_name_to_class
    describe '.type_name_to_class' do
      subject { described_class.type_name_to_class(described_class.type_name) }

      it { is_expected.to eq(described_class) }
    end
  end

  describe 'validations' do
    subject { described_class.new }
    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_presence_of(:type) }
  end

  describe '.import_csv_row' do
    subject { described_class }
    it { is_expected.to respond_to(:import_csv_row) }
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

    describe ":with_keywords trait" do
      context 'when provided' do
        subject { FactoryBot.build(described_class.model_name.param_key, :with_keywords) }

        its(:keywords) { is_expected.to be_present }
      end
      context 'when not provided' do
        its(:keywords) { is_expected.not_to be_present }
      end
    end
    describe ":with_categories trait" do
      context 'when provided' do
        subject { FactoryBot.build(described_class.model_name.param_key, :with_categories) }

        its(:categories) { is_expected.to be_present }
      end
      context 'when not provided' do
        its(:keywords) { is_expected.not_to be_present }
      end
    end

    if valid
      it { is_expected.to be_valid }
    else
      it { is_expected.not_to be_valid }
    end
  end
end
