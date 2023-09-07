# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    text { 'MyText' }
    type { '' }
    nested { false }
  end
end
