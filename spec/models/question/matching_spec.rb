# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Matching do
  it_behaves_like "a Question", export_as_xml: true
  it_behaves_like "a Matching Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Matching") }
  its(:qti_max_value) { is_expected.to be_a(Integer) }

  let(:instance) { FactoryBot.build(:question_matching) }

  describe '#qti_choices' do
    it "is an Array of Choice objects" do
      expect(instance.qti_choices.all? { |r| r.is_a?(described_class::Choice) }).to be_truthy
    end
  end

  describe '#qti_response_conditions' do
    it "is an Array of ResponseCondition objects" do
      expect(instance.qti_response_conditions.all? { |r| r.is_a?(described_class::ResponseCondition) }).to be_truthy
    end
  end

  describe '#qti_responses' do
    it "is an Array of Response objects" do
      expect(instance.qti_responses.all? { |r| r.is_a?(described_class::Response) }).to be_truthy
    end
  end
end
