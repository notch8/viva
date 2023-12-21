# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

namespace :data do
  namespace :cleanup do
    desc "Clear all existing questions"
    task prompts: :environment do
      Question.destroy_all
    end
    desc "Clear all existing metadata related to questions"
    task metadata: :environment do
      Subject.destroy_all
      Keyword.destroy_all
    end
  end
  desc "Reset all question related information"
  task cleanup: ["data:cleanup:questions", "data:cleanup:metadata"]
end
