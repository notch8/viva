# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question::InvalidQuestion do
  subject(:instance) { described_class.new("ROW") }

  describe '#message' do
    it "raises and error" do
      expect { instance.message }.to raise_error(NotImplementedError)
    end
  end
end
