# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Level do
  describe '.names' do
    subject { described_class.names }
    it { is_expected.to be_a(Array) }
  end
end
