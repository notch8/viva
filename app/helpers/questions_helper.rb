# frozen_string_literal: true

module QuestionsHelper
  def image_tags_for(question)
    return if question.images.blank?

    question.images.map do |image|
      "<img src=\"/images/#{question.id}/#{CGI.escapeHTML(File.basename(image.url))}\" alt=\"#{CGI.escapeHTML(image.alt_text)}\">"
    end.join("\n      ").html_safe # rubocop:disable Rails/OutputSafety
  end
end
