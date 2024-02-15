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

  desc "Normalize existing keywords and subject"
  task normalize: :environment do
    [Subject, Keyword].each do |model|
      model.all.each do |record|
        next if record.name.downcase == record.name
        other = model.where(name: record.name.downcase).where.not(id: record.id).first
        if other
          # We want to move data from this record to the other
          join_table = Subject.reflections['questions'].join_table
          fk = Subject.reflections['questions'].foreign_key
          sql = "UPDATE #{join_table} SET #{fk} = #{other.id} WHERE #{fk} = #{record.id}"
          model.connection.execute(sql)
          record.destroy
        else
          record.update(name: record.name.downcase)
        end
      end
    end
  end
end
