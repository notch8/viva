# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    text { Faker::Lorem.unique.sentence }
    nested { false }
  end
end
