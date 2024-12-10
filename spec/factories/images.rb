# frozen_string_literal: true
FactoryBot.define do
  factory :image do
    alt_text { "Sample alt text" }
    question
    after(:build) do |image|
      image.file.attach(
        io: Rails.root.join('spec', 'fixtures', 'files', 'test_image.png').open,
        filename: 'test_image.png',
        content_type: 'image/png'
      )
    end
  end
end
