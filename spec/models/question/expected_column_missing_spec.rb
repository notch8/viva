# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::ExpectedColumnMissing do
  subject(:instance) { described_class.new(expected: ["IMPORT_ID", "TEXT", "TYPE"], given: ["IMPORT_ID", "ANSWER"]) }

  it { is_expected.not_to be_valid }

  describe '#errors' do
    subject { instance.errors }

    its(:keys) { is_expected.to match_array([:expected, :given, :missing]) }
  end
end
