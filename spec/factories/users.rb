# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    password { 'password' }
    email { Faker::Internet.unique.safe_email }
  end
end
