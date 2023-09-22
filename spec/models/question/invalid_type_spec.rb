# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::InvalidType do
  subject { described_class.new(CsvRow.new("TYPE" => "Wonky")) }
  it { is_expected.not_to be_valid }
end
