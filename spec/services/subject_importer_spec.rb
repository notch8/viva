# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectImporter do
  let(:subject) { described_class.import('spec/fixtures/files/subjects_to_import.yaml') }
  let(:setting_names_array) do
    subjects_data = YAML.load_file('spec/fixtures/files/subjects_to_import.yaml')
    subjects_data['subjects']['name'].map(&:downcase).uniq
  end

  it 'creates subjects all in lower case' do
    expect { subject }.to change(Subject, :count).by(setting_names_array.size)
    expect(Subject.pluck(:name)).to match_array(setting_names_array)
  end

  describe 'does not create duplicate subjects' do
    before do
      subject
    end
    it 'does not create duplicate subjects' do
      expect { subject }.not_to change(Subject, :count)
    end
  end
end
