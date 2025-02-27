# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::InvalidSubject do
  subject { described_class.new(CsvRow.new("SUBJECT" => 'anything')) }
  it { is_expected.not_to be_valid }
end
