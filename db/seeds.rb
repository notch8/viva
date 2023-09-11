# frozen_string_literal: true

##
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
abort "Don't run this in production" if Rails.env.production?

if ENV['DEFAULT_USER_EMAIL'] && ENV['DEFAULT_USER_PASSWORD']
  u = User.find_or_create_by(email: ENV['DEFAULT_USER_EMAIL']) do |u|
    u.password = ENV['DEFAULT_USER_PASSWORD']
  end
end


# This is some very random data to quickly populate a non-production instance.
[Keyword, Category, Question].each(&:destroy_all)

keywords = (1..10).map do |i|
  Keyword.create!(name: Faker::Lorem.unique.word)
end

categories = (1..10).map do |i|
  Category.create!(name: Faker::Lorem.unique.word)
end

types = ['Question::SelectAllThatApply', 'Question::StimulusCaseStudy', 'Question::Matching', 'Question::Traditional', 'Question::DragAndDrop']

(1..10).each do |i|
  question = Question.create!(text: Faker::Lorem.unique.sentence, type: types.first)
  question.keywords = keywords.shuffle[0..rand(4)]
  question.categories = categories.shuffle[0..rand(2)]
  question.save!

  types = types.rotate
end
