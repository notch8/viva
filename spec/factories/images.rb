# frozen_string_literal: true
FactoryBot.define do
  factory :image do
    transient do
      sequence_number { 1 }
    end

    alt_text { "Sample alt text" }
    question
    after(:build) do |image, evaluator|
      image.file.attach(
        io: Rails.root.join('spec', 'fixtures', 'files', "test_image_#{evaluator.sequence_number}.png").open,
        filename: "test_image_#{evaluator.sequence_number}.png",
        content_type: 'image/png'
      )
    end
  end
end
