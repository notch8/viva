# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Scenario do
  it_behaves_like "a Question", test_type_name_to_class: false, include_in_filterable_type: false
  its(:type_label) { is_expected.to eq("Scenario") }
  its(:type_name) { is_expected.to eq("Scenario") }

  subject { described_class.new }

  its(:child_of_aggregation) { is_expected.to eq(true) }
  its(:data) { is_expected.to be_nil }
end
