# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::NoType do
  subject { described_class.new(CsvRow.new("ANSWER" => "TRUE")) }
  it { is_expected.not_to be_valid }
end
