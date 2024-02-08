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

    desc "Clear all existing orphaned metadata related to questions"
    task orphaned_metadata: :environment do
      # This is not performant, and could be done with a left outer join into the joining table
      # where there are no entries in the joining table.  But that's not something I have time to
      # write.
      Subject.all.each do |s|
        next unless s.questions.count.zero?
        s.destroy
      end

      Keyword.all.each do |kw|
        next unless kw.questions.count.zero?
        kw.destroy
      end
    end
  end
  desc "Reset all question related information"
  task cleanup: ["data:cleanup:prompts", "data:cleanup:metadata"]
end
