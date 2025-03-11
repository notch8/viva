# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Upload, type: :model do
  it_behaves_like "a Question", valid: true, export_as_xml: true
  it_behaves_like "a Markdown Question"

  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Upload") }
  its(:model_exporter) { is_expected.to eq('essay_type') }
  its(:export_as_xml) { is_expected.to eq(true) }
  its(:d2l_export_type) { is_expected.to eq('WR') }
end
