# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectImporter do
  let(:subject) { described_class.import('spec/fixtures/files/subjects_to_import.yaml') }

  describe 'does not create duplicate subjects' do
    it 'creates exactly 3 new subjects' do
      expect { subject }.to change(Subject, :count).by(3)
    end
  end
end
