# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::Essay do
  it_behaves_like "a Question", export_as_xml: true
  it_behaves_like "a Markdown Question"
  its(:type_label) { is_expected.to eq("Question") }
  its(:type_name) { is_expected.to eq("Essay") }
end
