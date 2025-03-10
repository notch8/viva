# frozen_string_literal: true

module QuestionsHelper
  def image_tags_for(question)
    return '' if question.images.blank?

    question.images.map do |image|
      "<img src=\"/images/#{File.basename(image.url)}\" alt=\"#{image.alt_text}\">"
    end.join
  end
end
