# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::GeneralCsvError do
  subject(:instance) { described_class.new(exception:) }

  let(:exception) { StandardError.new("Danger Will Robinsion") }

  it { is_expected.not_to be_valid }

  context '#errors' do
    subject { instance.errors }
    it 'is a hash with message key' do
      expect(subject.keys).to match_array([:message])
    end
  end
end
