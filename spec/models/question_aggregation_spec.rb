# frozen_string_literal: true
require 'rails_helper'

RSpec.describe QuestionAggregation, type: :model do
  it { is_expected.to belong_to(:child_question) }
  it { is_expected.to belong_to(:parent_question) }
end
