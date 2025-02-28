# frozen_string_literal: true

require 'yaml'

class SubjectImporter
  def self.import(file_path = 'config/subjects.yaml')
    subjects_data = YAML.load_file(file_path)
    subjects = subjects_data['subjects']['name']

    subjects.each do |subject_name|
      Subject.find_or_create_by(name: subject_name)
    end
  end
end
