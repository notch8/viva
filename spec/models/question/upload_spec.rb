# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Upload do
  it_behaves_like "a Question", canvas_export_type: true
  it_behaves_like "a Markdown Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Upload") }
end
