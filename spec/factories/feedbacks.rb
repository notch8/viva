# frozen_string_literal: true
FactoryBot.define do
  factory :feedback do
    content { "MyText" }
    resolved { false }
    user { nil }
    question { nil }
  end
end
