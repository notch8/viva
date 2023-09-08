# frozen_string_literal: true

FactoryBot.define do
  factory :keyword do
    name { Faker::Lorem.unique.word }
  end
end
