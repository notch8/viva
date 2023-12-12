# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Matching do
  it_behaves_like "a Question", export_as_xml: true
  it_behaves_like "a Matching Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Matching") }
  its(:qti_max_value) { is_expected.to be_a(Integer) }
end
