# frozen_string_literal: true

##
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'zip'

abort "Don't run this in production" if Rails.env.production?

if ENV['DEFAULT_USER_EMAIL'] && ENV['DEFAULT_USER_PASSWORD']
  u = User.find_or_create_by(email: ENV['DEFAULT_USER_EMAIL']) do |u|
    u.password = ENV['DEFAULT_USER_PASSWORD']
    u.admin = true
    u.active = true
  end
  # Update existing user if it already exists
  u.update(admin: true, active: true) if u.persisted?
end

u = User.find_or_create_by(email: ENV['INSTRUCTOR_USER_EMAIL1']) do |u|
  u.password = ENV['DEFAULT_USER_PASSWORD']
  u.active = true
end
# Update existing user if it already exists
u.update(active: true) if u.persisted?

u = User.find_or_create_by(email: ENV['INSTRUCTOR_USER_EMAIL2']) do |u|
  u.password = ENV['DEFAULT_USER_PASSWORD']
  u.active = true
end
# Update existing user if it already exists
u.update(active: true) if u.persisted?

user_id1 = User.find_by(email: ENV['INSTRUCTOR_USER_EMAIL1']).id
user_id2 = User.find_by(email: ENV['INSTRUCTOR_USER_EMAIL2']).id

# This is some very random data to quickly populate a non-production instance.
Subject.destroy_all

Question.find_each do |question|
  question.images.find_each do |image|
    image.file.purge if image.file.attached?
  end
end
Question.destroy_all

# require File.expand_path('../../spec/support/factory_bot', __FILE__)

# keywords = (1..10).map do |i|
#   FactoryBot.create(:keyword)
# end

# subjects = (1..10).map do |i|
#   FactoryBot.create(:subject)
# end

# Question.descendants.each do |qt|
#   (1..2).each do
#     question = FactoryBot.create(qt.model_name.param_key)
#     question.keywords = keywords.shuffle[0..rand(4)]
#     question.subjects = subjects.shuffle[0..rand(2)]
#     question.save!
#   end
# end

def zip_files(output_path, *files)
  Zip::File.open(output_path, Zip::File::CREATE) do |zipfile|
    files.each do |file_path|
      zipfile.add(File.basename(file_path), file_path)
    end
  end

  yield File.open(output_path) if block_given?
ensure
  File.delete(output_path) if File.exist?(output_path)
end

SubjectImporter.import
subjects = Subject.all
questions = []

###### Upload Questions
upload_questions_csv = File.open(Rails.root.join("db", "seed_csvs", "upload_questions.csv"))
questions << Question::ImporterCsv.from_file(upload_questions_csv, user_id: user_id1)

###### Multiple Choice Questions
csv_path = Rails.root.join("db", "seed_csvs", "multiple_choice_questions.csv")
image_path = Rails.root.join("db", "seed_images", "cat-injured.jpg")
zip_path = Rails.root.join("tmp", "multiple_choice_questions.zip")

zip_files(zip_path, csv_path, image_path) do |zip_file|
  questions << Question::ImporterCsv.from_file(zip_file, user_id: user_id2)
end

###### Select all that apply Questions
csv_path = Rails.root.join("db", "seed_csvs", "sata_questions.csv")
image_path = Rails.root.join("db", "seed_images", "dog-injured.jpg")
zip_path = Rails.root.join("tmp", "sata_questions.zip")

zip_files(zip_path, csv_path, image_path) do |zip_file|
  questions << Question::ImporterCsv.from_file(zip_file, user_id: user_id2)
end

#### Matching Questions
matching_questions_csv = File.open(Rails.root.join("db", "seed_csvs", "matching_questions.csv"))
questions << Question::ImporterCsv.from_file(matching_questions_csv, user_id: user_id1)

###### Essay Questions
essay_questions_csv = File.open(Rails.root.join("db", "seed_csvs", "essay_questions.csv"))
questions << Question::ImporterCsv.from_file(essay_questions_csv, user_id: user_id2)

###### Drag and Drop Questions
csv_path = Rails.root.join("db", "seed_csvs", "drag_and_drop_questions.csv")
image_path = Rails.root.join("db", "seed_images", "brain.jpg")
zip_path = Rails.root.join("tmp", "drag_and_drop_questions.zip")

zip_files(zip_path, csv_path, image_path) do |zip_file|
  questions << Question::ImporterCsv.from_file(zip_file, user_id: user_id2)
end

###### Categorization Questions
categorization_questions_csv = File.open(Rails.root.join("db", "seed_csvs", "categorization_questions.csv"))
questions << Question::ImporterCsv.from_file(categorization_questions_csv, user_id: user_id2)

###### Bow Tie Questions
bow_tie_questions_csv = File.open(Rails.root.join("db", "seed_csvs", "bow_tie_questions.csv"))
questions << Question::ImporterCsv.from_file(bow_tie_questions_csv, user_id: user_id2)

###### Stimulus Case Study Questions
csv_path = Rails.root.join("db", "seed_csvs", "stimulus_case_study_questions.csv")
image_path_1 = Rails.root.join("db", "seed_images", "chest-xray.jpg")
image_path_2 = Rails.root.join("db", "seed_images", "brain-ct.jpg")
zip_path = Rails.root.join("tmp", "stimulus_case_study_questions.zip")

zip_files(zip_path, csv_path, image_path_1, image_path_2) do |zip_file|
  questions << Question::ImporterCsv.from_file(zip_file, user_id: user_id2)
end

questions.shuffle.each(&:save)

# Cleanup at the end
FileUtils.rm_rf(Rails.root.join("tmp", "unzipped"))
Dir.glob(Rails.root.join("tmp", "*.zip")).each { |f| File.delete(f) }
