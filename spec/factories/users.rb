# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    password { 'password' }
    email { Faker::Internet.unique.safe_email }
    active { true }
    admin { false }

    trait :admin do
      admin { true }
    end

    trait :inactive do
      active { false }
    end

    trait :invited do
      invitation_token { Devise.friendly_token }
      invitation_sent_at { Time.current }
      invitation_created_at { Time.current }
    end
  end
end
