# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Scenario do
  it_behaves_like "a Question", test_type_name_to_class: false, include_in_filterable_type: false

  subject { described_class.new }

  its(:child_of_aggregation) { is_expected.to eq(true) }
end
